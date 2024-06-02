#!/bin/zsh


# Define colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to keep sudo alive
keep_sudo_alive() {
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Function to install Xcode CLI tools
install_xcode() {
    if ! xcode-select -p > /dev/null 2>&1; then
        echo "Xcode CLI tools are not installed, installing..."
        xcode-select --install
        echo "Xcode CLI tools installed successfully."
    else
        echo "Xcode CLI tools are already installed."
    fi
}

# Function to install Homebrew
install_homebrew() {
    echo "Checking for Homebrew..."
    if ! command -v brew > /dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed. Updating and upgrading..."
        brew update && brew upgrade
    fi
}

# Function to install packages
install_packages() {
    PACKAGES=(
        git
        node
        yarn
        python
        wget
        tree
        htop
        azure-cli
        kubectl
        fzf
        bat
        ansible
        tmux
        neovim
        helm
        httpie
        jq
        pyenv
        pyenv-virtualenv
        aws-vault
        gh
        # exa
        k9s
        kube-ps1
        stern
        dive
    )

    echo "Tapping additional repositories..."
    brew tap instrumenta/instrumenta
    brew tap stelligent/tap

    echo "Installing packages..."
    for package in "${PACKAGES[@]}"; do
        if brew list "$package" &>/dev/null; then
            echo "$package is already installed."
        else
            brew install "$package"
        fi
    done
}

# Function to install cask applications
install_cask_apps() {
    CASKS=(
        slack
        spotify
        visual-studio-code
        google-chrome
        firefox
        1password
        notion
        docker
        iterm2
        openbb-terminal
    )

    echo "Installing cask apps..."
    for cask in "${CASKS[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            echo "$cask is already installed."
        else
            brew install --cask "$cask"
        fi
    done
}

install_cloud_clis() {
  echo "Installing Cloud CLIs..."

  # AWS CLI
  if ! command -v aws >/dev/null 2>&1; then
    echo "Installing AWS CLI..."
    if [[ $(uname -s) == "Darwin" ]]; then  # macOS
      brew install awscli
    elif [[ $(uname -s) == "Linux" ]]; then  # Linux
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      rm -rf awscliv2.zip aws
    else
      echo "Unsupported OS. Please install AWS CLI manually."
    fi
  else
    echo "AWS CLI already installed."
  fi

  # Azure CLI
  if ! command -v az >/dev/null 2>&1; then
    echo "Installing Azure CLI..."
    if [[ $(uname -s) == "Darwin" ]]; then  # macOS
      brew update && brew install azure-cli
    elif [[ $(uname -s) == "Linux" ]]; then  # Linux
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    else
      echo "Unsupported OS. Please install Azure CLI manually."
    fi
  else
    echo "Azure CLI already installed."
  fi

  # GCP CLI (gcloud)
  if ! command -v gcloud >/dev/null 2>&1; then
    echo "Installing GCP CLI..."
    if [[ $(uname -s) == "Darwin" ]]; then  # macOS
      brew install --cask google-cloud-sdk
    elif [[ $(uname -s) == "Linux" ]]; then  # Linux
      curl https://sdk.cloud.google.com | bash
      exec -l $SHELL
    else
      echo "Unsupported OS. Please install GCP CLI manually."
    fi
  else
    echo "GCP CLI already installed."
  fi

  echo "Cloud CLIs installation complete."
}

# Function to install and configure Zsh
install_configure_zsh() {
    echo "Installing and Configuring Zsh..."

    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Set ZSH_CUSTOM directory (if not already set)
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # Clone Powerlevel10k theme
    echo "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

    # Clone Zsh plugins
    echo "Cloning Zsh plugins..."
    PLUGINS=(
        zsh-users/zsh-autosuggestions
        zsh-users/zsh-syntax-highlighting
        zsh-users/zsh-completions
        zsh-users/zsh-history-substring-search
    )

    for plugin in "${PLUGINS[@]}"; do
        git clone --depth=1 "https://github.com/$plugin.git" "$ZSH_CUSTOM/plugins/$(basename $plugin)"
    done

    # Copy custom files into $ZSH_CUSTOM
    cp .zshrc "$ZSH_CUSTOM/"
    cp aliaszsh "$ZSH_CUSTOM/aliases.zsh"
    cp functions.sh "$ZSH_CUSTOM/functions.zsh"
    cp aws_functions.sh "$ZSH_CUSTOM/aws_functions.zsh"

    # Update .zshrc (source your custom zshrc)
    echo "Updating .zshrc..."
    cat > ~/.zshrc <<EOF
# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load your custom zshrc from $ZSH_CUSTOM
source "$ZSH_CUSTOM/.zshrc"
EOF
}

# Function to configure macOS settings
configure_macos() {
    echo "Configuring macOS settings..."

    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15 
    # Require password as soon as screensaver or sleep mode starts
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    # Show filename extensions by default
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # Enable tap-to-click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Additional macOS settings
    defaults write com.apple.screencapture location -string "${HOME}/Documents/Screenshots"
    defaults write com.apple.screencapture disable-shadow -bool true
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.finder DisableAllAnimations -bool true
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.dock tilesize -int 50
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock show-process-indicators -bool true
    defaults write com.apple.dock showhidden -bool true
    defaults write com.apple.dock show-recents -bool false
}

# Function to create directories
create_directories() {
    echo "Creating Projects directory..."
    mkdir -p ${HOME}/Projects
    chmod 777 ${HOME}/Projects
}

# Function to setup Git and SSH keys
setup_git_ssh() {
    echo "Setting up Git and SSH keys..."

    # Generate SSH key
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "Generating SSH key..."
        ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/id_rsa -N ""
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_rsa
        echo "SSH key generated. Please add the following public key to your GitHub account:"
        cat ~/.ssh/id_rsa.pub
    else
        echo "SSH key already exists."
    fi

    # Set global Git configurations
    git config --global user.name "Your Name"
    git config --global user.email "your_email@example.com"
    git config --global core.editor "nano"
}

# Function to configure Visual Studio Code
configure_vscode() {
    echo "Configuring Visual Studio Code..."
    # Install MesloLGS NF font for Powerlevel10k (VS Code integrated terminal)
    echo "Installing MesloLGS NF font for Powerlevel10k..."
    mkdir -p "$HOME/Library/Fonts"
    curl -fLo "$HOME/Library/Fonts/MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    
    VSCODE_EXTENSIONS=(
        ms-python.python
        ms-toolsai.jupyter
        hashicorp.terraform
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        eamodio.gitlens
        esbenp.prettier-vscode
        redhat.vscode-yaml
        yzhang.markdown-all-in-one
        visualstudioexptteam.vscodeintellicode
        vscode-icons-team.vscode-icons
    )

    echo "Installing Visual Studio Code extensions..."
    for extension in "${VSCODE_EXTENSIONS[@]}"; do
        code --install-extension "$extension"
    done

    echo "Updating Visual Studio Code settings..."
    cp settings.json ~/Library/Application\ Support/Code/User/settings.json
    jq '. += {"terminal.integrated.fontFamily": "MesloLGS NF"}' "$HOME/Library/Application Support/Code/User/settings.json" | sponge "$HOME/Library/Application Support/Code/User/settings.json"
}

# Function to enhance security
enhance_security() {
    echo "Enhancing system security..."

    # Enable FileVault
    sudo fdesetup enable

    # Enable Firewall
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

    # Enable Stealth Mode
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

    # Enable automatic updates
    sudo softwareupdate --schedule on

    # Install and configure antivirus
    echo "Installing and configuring antivirus..."
    brew install --cask malwarebytes
    sudo /Applications/Malwarebytes.app/Contents/MacOS/Malwarebytes -installAutoLaunch
}
# Function to setup Python environment using pyenv
setup_python() {
    echo "Setting up Python environment with pyenv..."

    # Install pyenv and pyenv-virtualenv
    if ! command -v pyenv > /dev/null 2>&1; then
        curl https://pyenv.run | bash
    fi

    # Add pyenv to bash so it loads every time a new shell is opened
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

    # Reload shell
    source ~/.zshrc

    # Install Python versions
    pyenv install -s 3.9.6
    pyenv install -s 3.8.12
    pyenv global 3.9.6
}
# Function to configure iTerm2
configure_iterm2() {
  echo "Configuring iTerm2 with a Powerlevel10k-friendly dark theme..."

  # Ensure the directory exists
  mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles/

  # Powerlevel10k Dark configuration (with improved colors and settings)
  cat <<EOF > ~/Library/Application\ Support/iTerm2/DynamicProfiles/powerlevel10k.json
  {
    "Profiles": [
        {
            "Name": "Powerlevel10k Dark",
            "Guid": "00000000-0000-0000-0000-000000000001",
            "Custom Command": "No",
            "Command": "",
            "Initial Text": "",
            "Tags": [],
            "Working Directory": "Reuse Previous Sessions Directory",
            "Bound": "Yes",
            "Columns": 90,
            "Rows": 25,
            "Transparency": 0.0,
            "Horizontal Spacing": 1,
            "Vertical Spacing": 1,
            "History": 10000,
            "Cursor Type": "Underlined Bar",
            "Blinking Cursor": true,
            "Use Character Cell Width": false,
            "Non-ASCII Characters Ambiguous Width": true,
            "ASCII AntiAliased": true,
            "ASCII As Double Width": false,
            "ASCII Bold As Bright": true,
            "ASCII Use Italic": true,
            "ASCII Use Bold": true,
            "Character Spacing": 1.0,
            "Mouse Reporting": true,
            "Semantic History": "Open files with default application",
            "Background Color": {
                "Color Space": "sRGB",
                "Red Component": 0.12,   
                "Green Component": 0.15,  
                "Blue Component": 0.18    
            },
            "Foreground Color": {
                "Color Space": "sRGB",
                "Red Component": 0.75, 
                "Green Component": 0.80,
                "Blue Component": 0.85
            },
            "Ansi 0 Color": {
                "Color Space": "sRGB",
                "Red Component": 0.0,
                "Green Component": 0.0,
                "Blue Component": 0.0
            },
            "Ansi 8 Color": {
                "Color Space": "sRGB",
                "Red Component": 0.5,
                "Green Component": 0.5,
                "Blue Component": 0.5
            }, 
            "Minimum Contrast": 1.0
        }
    ]
    }
EOF
    # Tell the user to activate the new profile
    echo "Please activate the 'Powerlevel10k Dark' profile in iTerm2's Profiles settings."
}


# Function to clean up the system
cleanup_system() {
    echo "Cleaning up system..."
    brew cleanup --prune=2
    brew doctor
}

# Main function to run all setups
main() {
    printf "%s\n" "$GREEN"
    cat <<'EOF'
*****************************************
Your Device Setup will start now     
*****************************************
EOF
    printf "%s\n" "$NC"

    echo "Please enter root password..."
    sudo -v
    keep_sudo_alive
    install_xcode
    install_homebrew
    install_packages
    install_cask_apps
    install_cloud_clis
    install_configure_zsh
    configure_macos
    create_directories
    setup_git_ssh
    configure_vscode
    # enhance_security
    configure_iterm2
    setup_python
    cleanup_system

    echo "Setup complete. Some changes may require a restart to take effect."
}

main