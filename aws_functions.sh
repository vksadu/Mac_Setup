# Function to get AWS Account ID
aws_account_id() {
  aws sts get-caller-identity --query Account --output text
}

# Function to get AWS Identity and ARN
aws_identity() {
  aws sts get-caller-identity
}
## list EC2 instances 
ec2_list() {
  aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicDnsName]' --output table
}

ec2_ssh() {
  # Check if required tools are installed
  required_tools=(jq fzf aws nc)
  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      echo "$tool is required but not installed. Aborting."
      return 1
    fi
  done

  # Get AWS region and profile name
  local aws_profile=$(aws configure get profile | tr -d '\r')
  local aws_region=$(aws configure get region --profile "$aws_profile" | tr -d '\r')

  # Get list of running/stopped instances with instance ID, name, public IP, private IP, and key name
  local instances=$(aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running,stopped" \
    --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`] | [0].Value, PublicIpAddress, PrivateIpAddress, KeyName]' \
    --output text --region "$aws_region" --profile "$aws_profile")

  # Select an instance using fzf
  local selected=$(echo "$instances" | fzf --preview 'aws ec2 describe-instances --instance-ids {} --region "$aws_region" --profile "$aws_profile" | jq -r ".Reservations[].Instances[] | .InstanceId, .PublicIpAddress, .PrivateIpAddress, .KeyName"')

  if [[ -n "$selected" ]]; then
    local instance_id=$(echo "$selected" | awk '{print $1}')
    local public_ip=$(echo "$selected" | awk '{print $2}')
    local private_ip=$(echo "$selected" | awk '{print $3}')
    local key_name=$(echo "$selected" | awk '{print $4}')

    # Determine IP to use (prefer public IP if available)
    local ip_to_use=${public_ip:-$private_ip}

    if [[ -n "$key_name" ]]; then
      local ssh_user=${AWS_EC2_SSH_USER:-ec2-user}  # Use custom user if set
      local key_file="~/.ssh/$key_name.pem"

      if [ -f "$key_file" ]; then
        if nc -z -w1 "$ip_to_use" 22; then
          # Port 22 is open, use SSH directly
          open_ssh_session "$ip_to_use" "$key_file" "$ssh_user"
        else
          # Port 22 not open, try SSM Session Manager
          if aws ssm describe-instance-information --instance-id "$instance_id" --region "$aws_region" --profile "$aws_profile" &> /dev/null; then
            local local_port=$(find_next_available_port) || return 1  # Find available port for forwarding

            aws ssm start-session --target "$instance_id" --document-name AWS-StartSSHSession \
              --parameters portNumber=22 --region "$aws_region" --profile "$aws_profile" \
              --extra-parameters "LocalPortNumber=$local_port" || return 1  

            open_ssh_session "localhost" "$key_file" "$ssh_user" -p "$local_port"
          else
            echo "Error: Insufficient permissions for SSM Session Manager on $instance_id." >&2
            return 1
          fi
        fi
      else
        echo "Key file not found for instance $instance_id: $key_file. Aborting." >&2
        return 1
      fi
    else
      echo "Key name not found for instance $instance_id. Aborting." >&2
      return 1
    fi
  fi
}

# Helper function to open an SSH session
open_ssh_session() {
  local ip_address="$1"
  local key_file="$2"
  local user="$3"
  local port="${4:-22}"

  local terminal_emulator="${AWS_EC2_SSH_TERMINAL:-$(detect_terminal_emulator)}"

  if [[ -n "$terminal_emulator" ]]; then
    $terminal_emulator --tab -- bash -c "tmux new-session -A -s ssh_session 'ssh -i $key_file $user@$ip_address -p $port'"
  else
    ssh -i "$key_file" "$user@$ip_address" -p "$port" 
  fi
}

function find_next_available_port() {
  local port=2200  # Start from port 2200
  while ! nc -z -w1 127.0.0.1 $port &>/dev/null; do
    ((port++))
    if [[ $port -gt 2299 ]]; then
      echo "Error: No available local ports found."
      return 1
    fi
  done
  echo "$port"
}

ec2_health() {
    echo "Checking EC2 Instance Health..."

    # Get AWS region and profile name
    local aws_profile=$(aws configure get profile | tr -d '\r')
    local aws_region=$(aws configure get region --profile "$aws_profile" | tr -d '\r')

    # Get list of running/stopped instances with instance ID, name, public IP, private IP, and key name
    local instances=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`] | [0].Value, PublicIpAddress, PrivateIpAddress, KeyName]' \
        --output text --region "$aws_region" --profile "$aws_profile")

    # Select an instance using fzf
    local selected=$(echo "$instances" | fzf --preview "aws ec2 describe-instances --instance-ids {} --region $aws_region --profile $aws_profile | jq -r '.Reservations[].Instances[] | .InstanceId, .PublicIpAddress, .PrivateIpAddress, .KeyName'")

    if [[ -n "$selected" ]]; then
        local instance_id=$(echo "$selected" | awk '{print $1}')
        local public_ip=$(echo "$selected" | awk '{print $2}')
        local private_ip=$(echo "$selected" | awk '{print $3}')
        local key_name=$(echo "$selected" | awk '{print $4}')

        # Determine IP to use (prefer public IP if available)
        local ip_to_use=${public_ip:-$private_ip}

        if [[ -n "$key_name" ]]; then
            local ssh_user=${AWS_EC2_SSH_USER:-ec2-user}  # Use custom user if set
            local key_file="$HOME/.ssh/$key_name.pem"

            if [ -f "$key_file" ]; then
                # SSH and gather system health data
                local health_data=$(ssh -i "$key_file" "$ssh_user@$ip_to_use" -q <<EOF
                    echo "Uptime & Load: $(uptime)"
                    echo -e "\nMemory Usage:\n$(free -h)"
                    echo -e "\nDisk Usage:\n$(df -h)"
                    echo -e "\nCPU Information:\n$(lscpu)"
                    echo -e "\nNetwork Interfaces & IPs:\n$(ifconfig)"
                    echo -e "\nTop 5 Processes (CPU):\n$(ps aux | sort -nrk 3 | head -n 6)"
                    echo -e "\nTop 5 Processes (Memory):\n$(ps aux | sort -nrk 4 | head -n 6)"
EOF
                )

                # Format and display results in a table
                echo "$health_data" | column -t | awk '{ printf "%-25s %s\n", $1, $2 }' | sed 's/\t/  /g'  
            else
                echo "Key file not found: $key_file" >&2
            fi
        else
            echo "Key name not found for instance $instance_id." >&2
        fi
    fi
}



ec2_logs() {
    local log_path="$1"  # Optional argument for the log file path

    # Get AWS region and profile name
    local aws_profile=$(aws configure get profile | tr -d '\r')
    local aws_region=$(aws configure get region --profile "$aws_profile" | tr -d '\r')

    # Get list of running/stopped instances with instance ID, name, public IP, private IP, and key name
    local instances=$(aws ec2 describe-instances \
        --filters "Name=instance-state-name,Values=running,stopped" \
        --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`] | [0].Value, PublicIpAddress, PrivateIpAddress, KeyName]' \
        --output text --region "$aws_region" --profile "$aws_profile")

    # Select an instance using fzf
    local selected=$(echo "$instances" | fzf --preview 'aws ec2 describe-instances --instance-ids {} --region "$aws_region" --profile "$aws_profile" | jq -r ".Reservations[].Instances[] | .InstanceId, .PublicIpAddress, .PrivateIpAddress, .KeyName"')

    if [[ -n "$selected" ]]; then
        local instance_id=$(echo "$selected" | awk '{print $1}')
        local public_ip=$(echo "$selected" | awk '{print $2}')
        local private_ip=$(echo "$selected" | awk '{print $3}')
        local key_name=$(echo "$selected" | awk '{print $4}')

        # Determine IP to use (prefer public IP if available)
        local ip_to_use=${public_ip:-$private_ip}

        if [[ -n "$key_name" ]]; then
            local ssh_user=${AWS_EC2_SSH_USER:-ec2-user}  # Use custom user if set
            local key_file="~/.ssh/$key_name.pem"

            if [ -f "$key_file" ]; then
                # Set default log paths if none provided
                if [[ -z "$log_path" ]]; then
                    if [[ $ssh_user == "ec2-user" ]]; then
                        log_path="/var/log/cloud-init-output.log"
                    elif [[ $ssh_user == "ubuntu" ]]; then
                        log_path="/var/log/syslog"
                    else
                        echo "Unknown default log path for user '$ssh_user'. Please specify a log path."
                        return 1
                    fi
                fi

                # Open SSH session and display or tail logs
                local ssh_command="ssh -i $key_file $ssh_user@$ip_to_use"
                if [[ $log_path == *"-"* ]]; then # Check if argument starts with '-' to indicate tail
                    ssh_command+=" tail -f $log_path"
                else
                    ssh_command+=" cat $log_path"
                fi

                # Run SSH command
                eval "$ssh_command"
            else
                echo "Key file not found: $key_file" >&2
            fi
        else
            echo "Key name not found for instance $instance_id." >&2
        fi
    fi
}
