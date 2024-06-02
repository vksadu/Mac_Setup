# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
source "$ZSH/oh-my-zsh.sh"

# History Settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY  # Append to history, don't overwrite
setopt SHARE_HISTORY       # Share history across terminals
setopt EXTENDED_HISTORY    # Add timestamps to history entries
HIST_STAMPS="mm/dd/yyyy"  # Format for history timestamps

# Basic Autocompletion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)  # Include hidden files.

# Vi Mode Key Bindings
bindkey -v
export KEYTIMEOUT=1

# Preferred Editor
export EDITOR='vim'

# Plugins
plugins=(
  git
  bundler
  dotenv
  osx
  rake
  rbenv
  ruby
  zsh-autosuggestions
  history-substring-search
  zsh-apple-touchbar
  zsh-completions
  zsh-syntax-highlighting
  web-search
  kubectl
  docker
  aws
  xcode
  git-auto-fetch
  ansible
  brew
)
# Source Zsh Plugins
for plugin ($plugins); do
  source "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" 2> /dev/null
done

# Load Custom Configurations (with error handling)
[[ -f "$ZSH_CUSTOM/aliases.zsh" ]] && source "$ZSH_CUSTOM/aliases.zsh"
[[ -f "$ZSH_CUSTOM/functions.zsh" ]] && source "$ZSH_CUSTOM/functions.zsh"
[[ -f "$ZSH_CUSTOM/aws_functions.zsh" ]] && source "$ZSH_CUSTOM/aws_functions.zsh" 

# Powerlevel10k Theme
source "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme"
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"  # Load your custom p10k config

# Pyenv Configuration (if installed)
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init --path)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# Load other tools if installed
command -v kube-ps1 >/dev/null 2>&1 && source "$(brew --prefix kube-ps1)/share/kube-ps1.sh"
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)

# ... your other settings and functions

# ... other useful zsh options ...
setopt auto_cd              # Automatically change directory on typing the name
setopt correct              # Attempt to correct typos in commands
setopt auto_pushd           # Automatically pushd when changing directory
setopt pushd_ignore_dups    # Don't push the same dir twice

# Function to delete .DS_Store files
delete_ds_store() {
    find . -name ".DS_Store" -depth -delete 2>/dev/null 
}

# Hook the function to cd command
autoload -Uz chpwd_functions
chpwd_functions+=(delete_ds_store)

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. 
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files 
# under VCS as dirty. This makes repository status check for large repositories 
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to disable password hiding when typing.
# DISABLE_HIDE_INFO="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)