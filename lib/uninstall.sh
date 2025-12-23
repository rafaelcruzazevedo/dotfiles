#!/bin/zsh

# ============================================================================
# DOTFILES UNINSTALL FUNCTIONS
# ============================================================================

# ============================================================================
# UNINSTALL FUNCTIONS
# ============================================================================

remove_shell_symlinks() {
  print_step "Removing shell symlinks..."

  for file in ~/.zshrc ~/.vimrc ~/.gitconfig ~/.gitaliases; do
    if [ -L "$file" ]; then
      rm -f "$file"
      print_success "Removed $file"
    elif [ -f "$file" ]; then
      print_warning "$file exists but is not a symlink, skipping"
    fi
  done
}

remove_config_symlinks() {
  print_step "Removing config symlinks..."

  # Starship
  if [ -L ~/.config/starship.toml ]; then
    rm -f ~/.config/starship.toml
    print_success "Removed ~/.config/starship.toml"
  fi
}

remove_iterm_config() {
  print_step "Removing iTerm2 configuration..."

  local iterm_profile=~/Library/Application\ Support/iTerm2/DynamicProfiles/default.json
  if [ -L "$iterm_profile" ] || [ -f "$iterm_profile" ]; then
    rm -f "$iterm_profile"
    print_success "Removed iTerm2 dynamic profile"
  fi
}

remove_editor_config() {
  print_step "Removing editor configuration..."

  # Cursor
  local cursor_dir=~/Library/Application\ Support/Cursor/User
  for file in settings.json keybindings.json; do
    if [ -L "$cursor_dir/$file" ]; then
      rm -f "$cursor_dir/$file"
      print_success "Removed Cursor $file"
    fi
  done

  # VSCode
  local vscode_dir=~/Library/Application\ Support/Code/User
  if [ -L "$vscode_dir/settings.json" ]; then
    rm -f "$vscode_dir/settings.json"
    print_success "Removed VSCode settings.json"
  fi
}

remove_ai_config() {
  print_step "Removing AI CLI configuration..."

  # Claude Code
  if [ -L ~/.claude/settings.json ]; then
    rm -f ~/.claude/settings.json
    print_success "Removed Claude Code settings"
  fi

  if [ -L ~/.claude/CLAUDE.md ]; then
    rm -f ~/.claude/CLAUDE.md
    print_success "Removed Claude Code memory"
  fi

  # Claude Code Rules
  if [ -d ~/.claude/rules ]; then
    for rule in ~/.claude/rules/*.md; do
      if [ -L "$rule" ]; then
        rm -f "$rule"
      fi
    done
    rmdir ~/.claude/rules 2>/dev/null || true
    print_success "Removed Claude Code rules"
  fi

  # Claude Code Skills
  if [ -d ~/.claude/skills ]; then
    for skill in ~/.claude/skills/*/; do
      if [ -L "${skill%/}" ]; then
        rm -f "${skill%/}"
      fi
    done
    rmdir ~/.claude/skills 2>/dev/null || true
    print_success "Removed Claude Code skills"
  fi

  # Cursor MCP
  if [ -L ~/.cursor/mcp.json ]; then
    rm -f ~/.cursor/mcp.json
    print_success "Removed Cursor MCP config"
  fi

  # Gemini CLI
  if [ -L ~/.gemini/settings.json ]; then
    rm -f ~/.gemini/settings.json
    print_success "Removed Gemini CLI config"
  fi

  # Cleanup empty directories
  for dir in ~/.claude ~/.cursor ~/.gemini; do
    if [ -d "$dir" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
      rmdir "$dir" 2>/dev/null && print_success "Removed empty $dir"
    fi
  done
}

restore_backups() {
  print_step "Restoring backups..."

  # Check for .local backup files and restore them
  for local_file in ~/.zshrc.local ~/.vimrc.local ~/.gitconfig.local; do
    if [ -f "$local_file" ]; then
      original="${local_file%.local}"
      if [ ! -f "$original" ]; then
        print_warning "Found $local_file - this contains your personal config"
      fi
    fi
  done
}

remove_dotfiles_dir() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    return 0
  fi

  echo ""
  local confirm
  if has_gum; then
    if gum confirm "Remove $DOTFILES_DIR directory?"; then
      confirm="yes"
    fi
  else
    read -p "Remove $DOTFILES_DIR directory? [y/N] " confirm
  fi

  if [[ "$confirm" =~ ^[Yy] ]]; then
    # Safety check: ensure DOTFILES_DIR is set and within HOME
    if [ -z "$DOTFILES_DIR" ]; then
      print_error "DOTFILES_DIR is not set, refusing to delete"
      return 1
    fi
    if [[ "$DOTFILES_DIR" != "$HOME"* ]]; then
      print_error "DOTFILES_DIR ($DOTFILES_DIR) is not within HOME, refusing to delete"
      return 1
    fi
    rm -rf "$DOTFILES_DIR"
    print_success "Removed $DOTFILES_DIR"
  else
    print_warning "Kept $DOTFILES_DIR"
  fi
}

# ============================================================================
# MAIN UNINSTALL FUNCTION
# ============================================================================

do_uninstall() {
  print_header "Dotfiles Uninstall" "196"

  # Confirm before proceeding
  local proceed
  if has_gum; then
    if ! gum confirm "This will remove all dotfiles symlinks. Continue?"; then
      echo "Aborted."
      exit 0
    fi
  else
    read -p "This will remove all dotfiles symlinks. Continue? [y/N] " proceed
    if [[ ! "$proceed" =~ ^[Yy] ]]; then
      echo "Aborted."
      exit 0
    fi
  fi

  echo ""
  remove_shell_symlinks
  remove_config_symlinks
  remove_iterm_config
  remove_editor_config
  remove_ai_config
  restore_backups
  remove_dotfiles_dir

  echo ""
  print_success "Uninstall complete!"
  echo ""
  echo "Note: Homebrew packages were NOT removed."
  if [ -f "$HOME/.dotfiles/Brewfile" ]; then
    echo "To remove them: brew bundle cleanup --file=~/.dotfiles/Brewfile --force"
  fi
}
