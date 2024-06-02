# Mac_Setup


This script automates the setup of a macOS developer environment with essential tools, configurations, and security enhancements. It aims to streamline the process of getting system ready for coding and cloud development.

## Features

- **Installs Essential Tools:**
    - Xcode Command Line Tools
    - Homebrew (Package Manager)
    - Git, Node.js, Python, and other core developer tools
    - Cloud CLIs (AWS, Azure, GCP)
- **Installs Applications:**
    - Slack, Spotify, Visual Studio Code, Google Chrome, Firefox, 1Password, Notion, Docker, iTerm2
- **Configures Shell:**
    - Installs and configures Oh My Zsh with Powerlevel10k theme
    - Clones useful Zsh plugins (autosuggestions, syntax highlighting, etc.)
    - Sets up custom aliases and functions for enhanced productivity
- **Optimizes macOS Settings:**
    - Adjusts key repeat rate, screensaver/sleep behavior, filename extensions, tap-to-click, etc.
- **Creates Directories:**
    - Creates a `Projects` directory for convenient organization
- **Sets Up Git & SSH Keys:**
    - Generates an SSH key (if not present) and guides you to add it to your GitHub account
    - Sets global Git configurations (name, email, editor)
- **Configures Visual Studio Code:**
    - Installs essential extensions for Python, Jupyter, Terraform, Docker, Kubernetes, etc.
    - Sets up a custom color theme and other preferences
    - Installs MesloLGS NF font for optimal Powerlevel10k experience in the integrated terminal
- **Enhances Security (Optional):**
    - Enables FileVault disk encryption
    - Enables macOS Firewall with stealth mode
    - Enables automatic updates
    - Installs Malwarebytes antivirus (requires manual configuration)
- **Configures iTerm2:**
    - Sets up a Powerlevel10k-friendly dark theme in iTerm2
- **Sets Up Python Environment with pyenv:**
    - Installs `pyenv` and `pyenv-virtualenv` for managing Python versions
    - Installs Python 3.9.6 and 3.8.12
    - Sets Python 3.9.6 as the global default
- **Cleans Up System:**
    - Runs `brew cleanup` and `brew doctor` to keep your system tidy

## Prerequisites

- **macOS:** This script is designed for macOS.
- **Administrative Access:** You'll need to provide your administrator (sudo) password during the setup process.
- **Git:** Ensure Git is installed to clone the repository.

## How to Use

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/vksadu/Mac_Setup.git
2. **Navigate to the Directory:**
    ```bash
    cd Mac_Setup
3. **Make Executable:**
    ```bash
    chmod +x setup.sh
4. **Run:**
    ```bash
    ./setup.sh
5. Follow Instructions: The script will guide you through any additional steps required (e.g., adding your SSH key to GitHub, configuring Malwarebytes).

## Configuration Files

This script includes custom configuration files to streamline your setup. These files are located within the repository you cloned and will be automatically copied to the correct locations during the setup process:

    .zshrc: Your personalized Zsh configuration file (copied to ~/.zshrc).
    aliases.zsh: Custom Zsh aliases (copied to $ZSH_CUSTOM/aliases.zsh).
    functions.sh: Custom Zsh functions (copied to $ZSH_CUSTOM/functions.zsh).
    aws_functions.sh: AWS-specific Zsh functions (copied to $ZSH_CUSTOM/aws_functions.zsh).
    settings.json: Your preferred Visual Studio Code settings (copied to ~/Library/Application Support/Code/User/settings.json).

## Customization

    Packages and Applications: Edit the PACKAGES and CASKS arrays in the script to customize the list of installed packages and applications.
    VS Code Extensions: Modify the VSCODE_EXTENSIONS array to install your preferred VS Code extensions.
    macOS Settings: Add or remove defaults write commands in the configure_macos function to personalize your macOS settings.

## Disclaimer

    This script automates many setup tasks, but it's recommended to review the script before running it and understand the changes it makes to your system.
    Use this script at your own risk. The author is not responsible for any data loss or other issues that may occur during the setup process.

## Contributing

Feel free to contribute by suggesting improvements, reporting issues, or adding features.