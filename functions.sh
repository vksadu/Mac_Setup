# Function to generate ssh key
function sshKeyGen(){
  echo "What's the name of the Key (no spaces please)? ";
  read name;
  echo "What's the email associated with it? ";
  read email;
  ssh-keygen -t rsa -f ~/.ssh/id_rsa_$name -C "$email";
  ssh-add ~/.ssh/id_rsa_$name
  pbcopy < ~/.ssh/id_rsa_$name.pub;
  echo "SSH Key copied in your clipboard";
}
# Function to generate a random password (unattended, takes length as argument)
function randpassw() {
  local MAXSIZE="${1:-10}" # Default to 10 characters if not provided
  local char_sets=("a-z" "A-Z" "0-9" "!@#$%^&*") # Customizable sets

  local password=""
  for (( i=0; i<$MAXSIZE; i++ )); do
    local set_index=$((RANDOM % ${#char_sets[@]}))
    local char=$(echo {${char_sets[$set_index]}} | tr -d ' ')
    password+="${char:RANDOM%${#char}:1}" 
  done

  echo "$password"
}


# Function to extract archives (unattended, no overwrite, recursive)
function extract() {
  local archive="$1"
  local dest_dir="${2:-.}" # Extract to current dir if not provided

  if [ -f "$archive" ]; then
    case "$archive" in
      *.tar.bz2 | *.tbz2)   tar xjf "$archive" -C "$dest_dir" ;;
      *.tar.gz | *.tgz)    tar xzf "$archive" -C "$dest_dir" ;;
      *.bz2)       bunzip2 "$archive"     ;;
      *.rar)       unrar x "$archive" -o+ "$dest_dir" ;; # Non-interactive
      *.gz)        gunzip "$archive"      ;;
      *.tar)       tar xf "$archive" -C "$dest_dir" ;;
      *.zip)       unzip "$archive" -d "$dest_dir"   ;;
      *.Z)         uncompress "$archive"  ;;
      *.7z)        7z x "$archive" -o"$dest_dir"   ;; 
      *)           echo "Unsupported archive type: $archive" ;;
    esac
  else
    echo "Invalid file: $archive"
  fi
}

# Function to search for a file using MacOS Spotlight's metadata
function spotlight() { mdfind "kMDItemDisplayName == '$@'wc"; }

# Function to display useful host related information
function ii() {
  echo -e "\nYou are logged on ${RED}$HOST"
  echo -e "\nAdditional information:$NC " ; uname -a
  echo -e "\n${RED}Users logged on:$NC " ; w -h
  echo -e "\n${RED}Current date :$NC " ; date
  echo -e "\n${RED}Machine stats :$NC " ; uptime
  echo -e "\n${RED}Current network location :$NC " ; scselect
  echo -e "\n${RED}Public facing IP Address :$NC " ;myip
  #echo -e "\n${RED}DNS Configuration:$NC " ; scutil --dns
  echo
}

# # Function to generate SSH key
# function sshKeyGen(){
#   echo "What's the name of the Key (no spaces please)? ";
#   read name;
#   echo "What's the email associated with it? ";
#   read email;
#   ssh-keygen -t rsa -f ~/.ssh/id_rsa_$name -C "$email";
#   ssh-add ~/.ssh/id_rsa_$name
#   pbcopy < ~/.ssh/id_rsa_$name.pub;
#   echo "SSH Key copied in your clipboard";
# }

# # Function to generate a random password
# function randpassw() {
#   if [ -z $1 ]; then
#     MAXSIZE=10
#   else
#     MAXSIZE=$1
#   fi
#   array1=( 
#     q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D 
#     F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0 
#     \! \@ \$ \% \^ \& \* \! \@ \$ \% \^ \& \* \@ \$ \% \^ \& \* 
#   ) 
#   MODNUM=${#array1[*]} 
#   pwd_len=0 
#   while [ $pwd_len -lt $MAXSIZE ]; do 
#     index=$(($RANDOM%$MODNUM)) 
#     echo -n "${array1[$index]}" 
#     ((pwd_len++)) 
#   done 
#   echo 
# }

# Function to create a tree view of the current directory
function tree(){
  pwd
  ls -R | grep ":$" | \
  sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
}

# Function to generate a GitHub pull request URL
function gpr() {
  if [ $? -eq 0 ]; then
    github_url=$(git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@' -e 's%\.git$%%');
    branch_name=$(git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3);
    pr_url=$github_url"/compare/master..."$branch_name
    open $pr_url;
  else
    echo 'Failed to open a pull request.';
  fi
}

# Function to search manpages
function mans() {
  man $1 | grep -iC2 --color=always $2 | less
}

# Function to use lf to switch directories and bind it to ctrl-o
function lfcd () {
  tmp="$(mktemp)"
  lf -last-dir-path="$tmp" "$@"
  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
  fi
}

bindkey -s '^o' 'lfcd\n'

