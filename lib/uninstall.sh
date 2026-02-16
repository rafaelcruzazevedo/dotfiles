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
