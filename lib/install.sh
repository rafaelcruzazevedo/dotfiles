#!/bin/zsh
set -e

# ============================================================================
# DOTFILES INSTALLATION FUNCTIONS
# ============================================================================

# ============================================================================
# PREREQUISITES
# ============================================================================

check_prerequisites() {
  print_step "Checking prerequisites..."

  # System dependencies (ref: docs.brew.sh/Homebrew-on-Linux)
  print_step "Installing system dependencies..."
  sudo apt-get update
  sudo apt-get install -y build-essential procps curl file git zsh chromium-browser

  # Homebrew
  if ! command -v brew &>/dev/null && [ ! -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    print_step "Installing Homebrew..."
    if [ "$(id -u)" -eq 0 ]; then
      # Homebrew refuses to run as root — use a dedicated user
      useradd -m -s /bin/bash linuxbrew 2>/dev/null || true
      curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o /tmp/homebrew-install.sh
      sudo -u linuxbrew env NONINTERACTIVE=1 /bin/bash /tmp/homebrew-install.sh
      rm -f /tmp/homebrew-install.sh
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  fi
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  print_success "Prerequisites verified (build-essential, Homebrew)"
}

install_gum() {
  if has_gum; then
    return 0
  fi

  echo "Installing gum for better UI..."
  run_brew install gum 2>/dev/null || true
}

# ============================================================================
# SUDO KEEP-ALIVE
# ============================================================================

acquire_sudo() {
  print_step "Acquiring administrator privileges..."
  print_warning "Some packages require sudo. You'll be asked for your password once."

  # Ask for password upfront
  sudo -v

  # Keep sudo alive in background until script finishes
  (
    while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" 2>/dev/null || exit
    done
  ) &
  SUDO_KEEPALIVE_PID=$!

  print_success "Administrator privileges acquired"
}

cleanup_sudo() {
  if [ -n "$SUDO_KEEPALIVE_PID" ]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  fi
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_brew_packages() {
  print_step "Installing Homebrew packages..."

  local log_file="/tmp/brew-bundle-$(date +%Y%m%d-%H%M%S).log"
  local brewfile="$DOTFILES_DIR/Brewfile"

  # When running as root, linuxbrew user can't read files in /root/
  if [ "$(id -u)" -eq 0 ]; then
    cp "$brewfile" /tmp/dotfiles-Brewfile
    chmod 644 /tmp/dotfiles-Brewfile
    brewfile=/tmp/dotfiles-Brewfile
  fi

  # brew bundle returns non-zero if any package fails, but we want to continue
  set +e
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would run: brew bundle --file=$DOTFILES_DIR/Brewfile"
  else
    run_brew bundle --file="$brewfile" 2>&1 | tee "$log_file"
    local bundle_status=${PIPESTATUS[0]}
    if [ $bundle_status -ne 0 ]; then
      print_warning "Some packages failed to install. Check: $log_file"
    fi
  fi
  set -e

  rm -f /tmp/dotfiles-Brewfile

  print_success "Homebrew packages installed"
}

install_shell_symlinks() {
  print_step "Creating shell config symlinks..."

  # Shell configs
  for file in ".zshrc" ".vimrc"; do
    if [ -f ~/$file.local ]; then
      print_warning "$file.local exists, keeping backup"
    elif [ -f ~/$file ] && [[ "$DRY_RUN" != "true" ]]; then
      cp ~/$file ~/$file.local 2>/dev/null || true
    fi
    dry_ln "$DOTFILES_DIR/shell/$file" ~/$file
  done

  # Git config
  if [ -f ~/.gitconfig.local ]; then
    print_warning ".gitconfig.local exists, keeping backup"
  elif [ -f ~/.gitconfig ] && [[ "$DRY_RUN" != "true" ]]; then
    cp ~/.gitconfig ~/.gitconfig.local 2>/dev/null || true
  fi
  dry_ln "$DOTFILES_DIR/git/.gitconfig" ~/.gitconfig

  # Backup .gitaliases if it exists and is not a symlink
  if [ -f ~/.gitaliases ] && [ ! -L ~/.gitaliases ] && [[ "$DRY_RUN" != "true" ]]; then
    cp ~/.gitaliases ~/.gitaliases.backup.$(date +%Y%m%d) 2>/dev/null || true
    print_warning "Backed up existing .gitaliases"
  fi
  dry_ln "$DOTFILES_DIR/git/.gitaliases" ~/.gitaliases

  print_success "Shell symlinks created"
}

create_projects_folder() {
  print_step "Creating Projects folder..."

  local projects_dir="$HOME/Projects"

  if [ -d "$projects_dir" ]; then
    print_success "Projects folder already exists: $projects_dir"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would create: $projects_dir"
  else
    mkdir -p "$projects_dir"
    print_success "Created: $projects_dir"
  fi
}

configure_git_user() {
  print_step "Configuring Git user..."

  # Check if already configured
  local current_name=$(git config --global user.name 2>/dev/null || echo "")
  local current_email=$(git config --global user.email 2>/dev/null || echo "")

  if [ -n "$current_name" ] && [ -n "$current_email" ]; then
    print_success "Git user already configured: $current_name <$current_email>"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would ask for Git user name and email"
    return 0
  fi

  # Get name
  local name
  if has_gum; then
    name=$(gum input --placeholder "Your name (e.g., John Doe)" --width 50 --value "$current_name")
  else
    read -p "Git user name: " name
  fi

  if [ -z "$name" ]; then
    print_warning "No name provided, skipping Git user config"
    return 0
  fi

  # Get email
  local email
  if has_gum; then
    email=$(gum input --placeholder "Your email (e.g., john@example.com)" --width 50 --value "$current_email")
  else
    read -p "Git user email: " email
  fi

  if [ -z "$email" ]; then
    print_warning "No email provided, skipping Git user config"
    return 0
  fi

  # Configure git
  git config --global user.name "$name"
  git config --global user.email "$email"

  print_success "Git user configured: $name <$email>"
}

configure_starship() {
  print_step "Configuring Starship prompt..."
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p ~/.config
  fi

  # Backup starship.toml if it exists and is not a symlink
  if [ -f ~/.config/starship.toml ] && [ ! -L ~/.config/starship.toml ] && [[ "$DRY_RUN" != "true" ]]; then
    cp ~/.config/starship.toml ~/.config/starship.toml.backup.$(date +%Y%m%d) 2>/dev/null || true
    print_warning "Backed up existing starship.toml"
  fi

  dry_ln "$DOTFILES_DIR/shell/starship.toml" ~/.config/starship.toml
  print_success "Starship configured"
}

configure_fzf() {
  print_step "Configuring fzf..."
  if command -v fzf &> /dev/null && [[ "$DRY_RUN" != "true" ]]; then
    "${HOMEBREW_PREFIX:-/home/linuxbrew/.linuxbrew}/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
  fi
  print_success "fzf configured"
}

# ============================================================================
# MAIN INSTALL FUNCTION
# ============================================================================

do_install() {
  # Mark installation as in progress (for resume detection)
  if [[ "$DRY_RUN" != "true" ]]; then
    touch "$DOTFILES_DIR/.installing"
  fi

  # Show mode
  if [[ "$DRY_RUN" == "true" ]]; then
    echo ""
    echo "=== DRY RUN MODE ==="
    echo "No changes will be made."
    echo ""
  fi

  print_header "Dotfiles Installer" "212"

  # Prerequisites - skip if requested (already checked in bootstrap)
  if [[ "$SKIP_PREREQUISITES" != "true" ]]; then
    check_prerequisites
    install_gum
    # Now with nice UI
    print_header "Dotfiles Installer" "212"
  else
    print_warning "Skipping prerequisites check"
  fi

  # Acquire sudo once for all packages that need it
  if [[ "$DRY_RUN" != "true" ]]; then
    acquire_sudo
    trap cleanup_sudo EXIT
  fi

  # Sequential installation
  install_brew_packages
  install_shell_symlinks
  create_projects_folder
  configure_git_user
  configure_starship
  configure_fzf

  # Done
  echo ""
  if has_gum; then
    gum style --foreground 82 --bold "[ok] Installation complete!"
    echo ""
    gum style --foreground 248 "Next steps:"
  else
    print_success "Installation complete!"
    echo ""
    echo "Next steps:"
  fi
  echo "  1. Add secrets to ~/.zshrc.local:"
  echo "     - GITHUB_PERSONAL_ACCESS_TOKEN"
  echo "  2. Restart terminal (or run: source ~/.zshrc) to load new configs"

  # Mark installation as complete
  rm -f "$DOTFILES_DIR/.installing"
}

# ============================================================================
# UPDATE FUNCTION
# ============================================================================

do_update() {
  print_header "Dotfiles Update" "39"

  # Check if dotfiles dir exists
  if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "$DOTFILES_DIR not found"
    echo "Run bootstrap first: curl -fsSL https://raw.githubusercontent.com/rafazsh/dotfiles/linux/bootstrap | bash"
    exit 1
  fi

  cd "$DOTFILES_DIR"

  # Check for uncommitted changes
  if [ -n "$(git status --porcelain)" ]; then
    print_step "Stashing local changes..."
    git stash push -m "dotfiles-update-$(date +%Y%m%d-%H%M%S)"
  fi

  # Pull latest
  print_step "Pulling latest changes..."
  if has_gum; then
    gum spin --spinner dot --title "Fetching..." -- git fetch origin
  else
    git fetch origin
  fi

  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  git pull origin "$current_branch"
  print_success "Updated to latest"

  # Re-run install (skip prerequisites)
  print_step "Re-applying configuration..."
  SKIP_PREREQUISITES=true
  do_install

  echo ""
  print_success "Update complete!"
}
