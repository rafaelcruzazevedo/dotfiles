# ============================================================================
# ZSHRC - Modern Configuration (2025)
# ============================================================================

# Language
export LANG=en_US.UTF-8

# Dotfiles location (for portable scripts)
export DOTFILES_DIR="$HOME/.dotfiles"

# ============================================================================
# HOMEBREW (Apple Silicon)
# ============================================================================

if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================================
# ZPLUG - Plugin Manager
# ============================================================================

export ZPLUG_HOME=/opt/homebrew/opt/zplug
if [ -f "$ZPLUG_HOME/init.zsh" ]; then
  source "$ZPLUG_HOME/init.zsh"
else
  echo "Warning: zplug not installed. Run: brew install zplug"
fi

# Load plugins only if zplug is available
if type zplug &>/dev/null; then
  # Essential plugins
  zplug "zsh-users/zsh-completions"
  zplug "zsh-users/zsh-autosuggestions"
  zplug "zsh-users/zsh-syntax-highlighting", defer:2
  zplug "zsh-users/zsh-history-substring-search", defer:3

  # Git plugin (from oh-my-zsh, provides aliases like gco, gst, etc.)
  zplug "plugins/git", from:oh-my-zsh

  # Install plugins if missing
  if ! zplug check; then
      zplug install
  fi

  zplug load
fi

# ============================================================================
# MODERN CLI TOOLS
# ============================================================================

# eza (ls replacement)
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias tree='eza --tree --icons'

# bat (cat replacement)
alias cat='bat --paging=never'
alias catp='bat'  # with paging

# zoxide - smarter directory jumping (use 'z' instead of 'cd' for smart jumps)
# Note: We don't alias cd='z' to avoid breaking scripts that expect standard cd behavior
eval "$(zoxide init zsh)"
alias cdi='zi'    # interactive zoxide

# fzf - fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ============================================================================
# PROMPT - Starship
# ============================================================================

eval "$(starship init zsh)"

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Volta (Node.js version manager)
export VOLTA_HOME=$HOME/.volta
export PATH=$VOLTA_HOME/bin:$PATH

# Java (use system default if available)
if /usr/libexec/java_home &>/dev/null; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# ============================================================================
# ALIASES
# ============================================================================

alias pip=pip3

# Git shortcuts (additional to oh-my-zsh plugin)
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gco='git checkout'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'

# ============================================================================
# GPG / SSH
# ============================================================================

# Required for GPG signing in terminal
export GPG_TTY=$(tty)

# ============================================================================
# HISTORY
# ============================================================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_DUPS       # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show command before executing from history
setopt APPEND_HISTORY         # Append to history file, don't overwrite
setopt EXTENDED_HISTORY       # Record timestamp in history
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming

# ============================================================================
# iTerm2 SHELL INTEGRATION
# ============================================================================

# Provides: command navigation, directory history, file transfers
# https://iterm2.com/shell_integration.html
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# ============================================================================
# LOCAL CONFIG & SECRETS
# ============================================================================

# Source local environment (if exists)
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Source local zsh config (secrets, machine-specific)
[ -s "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
