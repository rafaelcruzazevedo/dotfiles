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
  local missing=()

  # Xcode CLT
  if ! xcode-select -p &> /dev/null; then
    missing+=("Xcode Command Line Tools")
  fi

  # Homebrew
  if ! command -v brew &> /dev/null; then
    missing+=("Homebrew")
  fi

  if [ ${#missing[@]} -gt 0 ]; then
    print_error "Missing prerequisites:"
    for dep in "${missing[@]}"; do
      echo "  - $dep"
    done
    echo ""
    echo "Install them first:"
    echo "  1. xcode-select --install"
    echo "  2. /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  3. Restart terminal, then run this command again"
    exit 1
  fi

  print_success "Prerequisites verified (Xcode CLT, Homebrew)"
}

install_gum() {
  if has_gum; then
    return 0
  fi

  echo "Installing gum for better UI..."
  brew install gum 2>/dev/null || true
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

  # brew bundle returns non-zero if any package fails, but we want to continue
  set +e
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would run: brew bundle --file=$DOTFILES_DIR/Brewfile"
  else
    brew bundle --file="$DOTFILES_DIR/Brewfile" 2>&1 | tee "$log_file"
    # zsh uses 'pipestatus' (lowercase, 1-indexed); PIPESTATUS is bash-only
    local bundle_status=${pipestatus[1]}
    if [ $bundle_status -ne 0 ]; then
      print_warning "Some packages failed to install. Check: $log_file"
    fi
  fi
  set -e

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

  # .gitaliases — dry_ln handles backup automatically
  dry_ln "$DOTFILES_DIR/git/.gitaliases" ~/.gitaliases

  # Global gitignore (referenced by .gitconfig core.excludesfile)
  dry_ln "$DOTFILES_DIR/git/.gitignore_global" ~/.gitignore_global

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
  # dry_ln handles backup automatically
  dry_ln "$DOTFILES_DIR/shell/starship.toml" ~/.config/starship.toml
  print_success "Starship configured"
}

configure_fzf() {
  print_step "Configuring fzf..."
  if command -v fzf &> /dev/null && [[ "$DRY_RUN" != "true" ]]; then
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
  fi
  print_success "fzf configured"
}

configure_iterm() {
  print_step "Configuring iTerm2..."
  local iterm_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  local iterm_profile="$iterm_dir/default.json"
  local expected_target="$DOTFILES_DIR/apps/iterm/profiles/default.json"

  # Idempotency: only skip if the symlink already points to the right place
  if [ -L "$iterm_profile" ] && [ "$(readlink "$iterm_profile")" = "$expected_target" ] && [[ "$DRY_RUN" != "true" ]]; then
    print_warning "iTerm2 already configured, skipping"
    return 0
  fi

  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p "$iterm_dir"
  fi
  dry_ln "$expected_target" "$iterm_profile"
  if [[ "$DRY_RUN" != "true" ]]; then
    source "$DOTFILES_DIR/apps/iterm/defaults"
  else
    echo "[dry-run] source $DOTFILES_DIR/apps/iterm/defaults"
  fi
  print_success "iTerm2 configured"
}

configure_iterm_shell_integration() {
  print_step "Installing iTerm2 Shell Integration..."
  local integration_file="$HOME/.iterm2_shell_integration.zsh"

  if [ -f "$integration_file" ]; then
    print_warning "Shell Integration already installed, skipping"
    return 0
  fi

  run_with_spinner "Downloading..." curl -fsSL https://iterm2.com/shell_integration/zsh -o "$integration_file"
  print_success "iTerm2 Shell Integration installed"
}

configure_macos() {
  print_step "Applying macOS defaults..."
  print_warning "This may ask for your password (sudo required for accessibility settings)"

  if [[ "$DRY_RUN" != "true" ]]; then
    source "$DOTFILES_DIR/macos/defaults"
  else
    echo "[dry-run] source $DOTFILES_DIR/macos/defaults"
  fi
  print_success "macOS defaults applied"
}

configure_cursor() {
  print_step "Configuring Cursor..."

  local cursor_dir="$HOME/Library/Application Support/Cursor/User"
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p "$cursor_dir"
  fi

  # Symlink settings and keybindings
  dry_ln "$DOTFILES_DIR/apps/cursor/settings.json" "$cursor_dir/settings.json"
  dry_ln "$DOTFILES_DIR/apps/cursor/keybindings.json" "$cursor_dir/keybindings.json"

  # Install extensions if Cursor CLI is available
  if command -v cursor &> /dev/null && [[ "$DRY_RUN" != "true" ]]; then
    print_step "Installing Cursor extensions..."
    local failed_extensions=()
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" ]] && continue
      if ! cursor --install-extension "$extension" 2>/dev/null; then
        failed_extensions+=("$extension")
      fi
    done < "$DOTFILES_DIR/apps/cursor/extensions.txt"

    if [ ${#failed_extensions[@]} -gt 0 ]; then
      print_warning "Failed to install extensions: ${failed_extensions[*]}"
    fi
  elif [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would install extensions from apps/cursor/extensions.txt"
  else
    print_warning "Cursor CLI not found, skipping extensions"
  fi

  print_success "Cursor configured"
}

configure_vscode() {
  print_step "Configuring VSCode..."

  local vscode_dir="$HOME/Library/Application Support/Code/User"
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p "$vscode_dir"
  fi

  # Use Cursor config (single source of truth - Cursor is a VSCode fork)
  dry_ln "$DOTFILES_DIR/apps/cursor/settings.json" "$vscode_dir/settings.json"

  # Install extensions if VSCode CLI is available
  if command -v code &> /dev/null && [[ "$DRY_RUN" != "true" ]]; then
    print_step "Installing VSCode extensions..."
    local failed_extensions=()
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" ]] && continue
      if ! code --install-extension "$extension" 2>/dev/null; then
        failed_extensions+=("$extension")
      fi
    done < "$DOTFILES_DIR/apps/cursor/extensions.txt"

    if [ ${#failed_extensions[@]} -gt 0 ]; then
      print_warning "Failed to install extensions: ${failed_extensions[*]}"
    fi
  elif [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would install extensions from apps/cursor/extensions.txt"
  else
    print_warning "VSCode CLI not found, skipping extensions"
  fi

  print_success "VSCode configured"
}

configure_editors() {
  print_step "Which editor(s) to configure?"

  local choice
  if has_gum; then
    choice=$(gum choose "Both (Cursor + VSCode)" "Cursor only" "VSCode only" "Skip")
  else
    echo "1) Both (Cursor + VSCode)"
    echo "2) Cursor only"
    echo "3) VSCode only"
    echo "4) Skip"
    read -p "Choice [1]: " choice
    choice=${choice:-1}
    case $choice in
      1) choice="Both (Cursor + VSCode)" ;;
      2) choice="Cursor only" ;;
      3) choice="VSCode only" ;;
      4) choice="Skip" ;;
    esac
  fi

  case "$choice" in
    "Both (Cursor + VSCode)")
      configure_cursor
      configure_vscode
      ;;
    "Cursor only")
      configure_cursor
      ;;
    "VSCode only")
      configure_vscode
      ;;
    "Skip")
      print_warning "Skipping editor configuration"
      ;;
  esac
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

  # Sequential installation (no choices needed)
  install_brew_packages
  install_shell_symlinks
  create_projects_folder
  configure_git_user
  configure_starship
  configure_fzf
  configure_iterm
  configure_iterm_shell_integration
  configure_macos
  configure_editors

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
  echo "     - FIGMA_API_KEY"
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
    echo "Run bootstrap first: curl -fsSL https://raw.githubusercontent.com/rafaelcruzazevedo/dotfiles/master/bootstrap | bash"
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
