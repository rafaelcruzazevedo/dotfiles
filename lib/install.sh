#!/bin/zsh

# ============================================================================
# DOTFILES INSTALLATION FUNCTIONS
# ============================================================================

# ============================================================================
# PREREQUISITES (Auto-install)
# ============================================================================

install_xcode_clt() {
  if xcode-select -p &> /dev/null; then
    print_success "Xcode CLT already installed"
    return 0
  fi

  print_step "Installing Xcode Command Line Tools..."
  xcode-select --install 2>/dev/null || true

  echo "Waiting for Xcode CLT installation..."
  echo "Please complete the installation dialog, then press Enter."
  read -r

  if xcode-select -p &> /dev/null; then
    print_success "Xcode CLT installed"
  else
    print_error "Xcode CLT installation failed"
    exit 1
  fi
}

install_homebrew() {
  if command -v brew &> /dev/null; then
    print_success "Homebrew already installed"
    return 0
  fi

  print_step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to PATH for this session (Apple Silicon)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  print_success "Homebrew installed"
}

install_gum() {
  if has_gum; then
    return 0
  fi

  echo "Installing gum for better UI..."
  brew install gum 2>/dev/null
}

# ============================================================================
# INSTALLATION FUNCTIONS
# ============================================================================

install_brew_packages() {
  print_step "Installing Homebrew packages..."
  run_with_spinner "Installing from Brewfile..." brew bundle --file="$DOTFILES_DIR/Brewfile"
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
  dry_ln "$DOTFILES_DIR/git/.gitaliases" ~/.gitaliases

  print_success "Shell symlinks created"
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
  if [ -e ~/Library/Application\ Support/iTerm2/DynamicProfiles ] && [[ "$DRY_RUN" != "true" ]]; then
    print_warning "iTerm2 already configured, skipping"
    return 0
  fi

  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
  fi
  dry_ln "$DOTFILES_DIR/apps/iterm/profiles/default.json" ~/Library/Application\ Support/iTerm2/DynamicProfiles/default.json
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
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" ]] && continue
      cursor --install-extension "$extension" 2>/dev/null || true
    done < "$DOTFILES_DIR/apps/cursor/extensions.txt"
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
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" ]] && continue
      code --install-extension "$extension" 2>/dev/null || true
    done < "$DOTFILES_DIR/apps/cursor/extensions.txt"
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

configure_ai_tools() {
  print_step "Configuring AI CLI tools..."

  # Claude Code
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p ~/.claude
  fi
  dry_ln "$DOTFILES_DIR/apps/claude/settings.json" ~/.claude/settings.json

  # CLAUDE.md (global memory)
  if [ -f "$DOTFILES_DIR/apps/claude/CLAUDE.md" ]; then
    dry_ln "$DOTFILES_DIR/apps/claude/CLAUDE.md" ~/.claude/CLAUDE.md
  fi

  # Claude Code Rules (symlink each file)
  if [ -d "$DOTFILES_DIR/apps/claude/rules" ]; then
    if [[ "$DRY_RUN" != "true" ]]; then
      mkdir -p ~/.claude/rules
    fi
    for rule in "$DOTFILES_DIR/apps/claude/rules"/*.md; do
      if [ -f "$rule" ]; then
        dry_ln "$rule" ~/.claude/rules/$(basename "$rule")
      fi
    done
    print_success "Claude Code rules configured"
  fi

  # Claude Code Skills (symlink entire directories)
  if [ -d "$DOTFILES_DIR/apps/claude/skills" ]; then
    if [[ "$DRY_RUN" != "true" ]]; then
      mkdir -p ~/.claude/skills
    fi
    for skill_dir in "$DOTFILES_DIR/apps/claude/skills"/*/; do
      if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        dry_ln "$skill_dir" ~/.claude/skills/"$skill_name"
      fi
    done
    print_success "Claude Code skills configured"
  fi

  print_success "Claude Code configured"

  # Claude Code MCPs (user scope - available in all projects)
  if command -v claude &> /dev/null && [[ "$DRY_RUN" != "true" ]]; then
    print_step "Adding global MCPs..."
    claude mcp add context7 --scope user --transport http https://mcp.context7.com/mcp 2>/dev/null || true
    claude mcp add sequential-thinking --scope user -- npx -y @modelcontextprotocol/server-sequential-thinking 2>/dev/null || true
    print_success "Global MCPs configured"
  elif [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] Would add global MCPs: context7, sequential-thinking"
  fi

  # Cursor MCP (global)
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p ~/.cursor
  fi
  dry_ln "$DOTFILES_DIR/apps/cursor/mcp.json" ~/.cursor/mcp.json
  print_success "Cursor MCP configured"

  # Gemini CLI
  if command -v gemini &> /dev/null || [[ "$DRY_RUN" == "true" ]]; then
    if [[ "$DRY_RUN" != "true" ]]; then
      mkdir -p ~/.gemini
    fi
    dry_ln "$DOTFILES_DIR/apps/gemini/settings.json" ~/.gemini/settings.json
    print_success "Gemini CLI configured"
  else
    print_warning "Gemini CLI not installed, skipping"
  fi
}

# ============================================================================
# MAIN INSTALL FUNCTION
# ============================================================================

do_install() {
  # Show mode
  if [[ "$DRY_RUN" == "true" ]]; then
    echo ""
    echo "=== DRY RUN MODE ==="
    echo "No changes will be made."
    echo ""
  fi

  print_header "Dotfiles Installer" "212"

  # Prerequisites (auto-install) - skip if requested
  if [[ "$SKIP_PREREQUISITES" != "true" ]]; then
    install_xcode_clt
    install_homebrew
    install_gum
    # Now with nice UI
    print_header "Dotfiles Installer" "212"
  else
    print_warning "Skipping prerequisites (--skip-prerequisites)"
  fi

  # Sequential installation (no choices needed)
  install_brew_packages
  install_shell_symlinks
  configure_git_user
  configure_starship
  configure_fzf
  configure_iterm
  configure_iterm_shell_integration
  configure_macos
  configure_editors
  configure_ai_tools

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
  echo "  2. Restart terminal or run: source ~/.zshrc"
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
