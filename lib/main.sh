#!/bin/zsh
set -e

# ============================================================================
# DOTFILES MAIN
# ============================================================================
# Core logic for dotfiles management
# ============================================================================

# Export DOTFILES_DIR (set by bootstrap)
export DOTFILES_DIR

# Flags
export DRY_RUN=false
export SKIP_PREREQUISITES=false

# Source libraries (with error handling)
for lib in helpers.sh install.sh uninstall.sh; do
  if [ -f "$DOTFILES_DIR/lib/$lib" ]; then
    source "$DOTFILES_DIR/lib/$lib" || { echo "Error: Failed to source lib/$lib"; exit 1; }
  else
    echo "Error: lib/$lib not found"
    exit 1
  fi
done

# ============================================================================
# MENU
# ============================================================================

show_menu() {
  print_header "Dotfiles Manager" "212"

  local choice
  if has_gum; then
    choice=$(gum choose \
      "Install (fresh setup)" \
      "Update (pull + re-apply)" \
      "Uninstall (remove all)" \
      "Dry Run (preview changes)")
  else
    echo "What would you like to do?"
    echo ""
    echo "  1) Install (fresh setup)"
    echo "  2) Update (pull + re-apply)"
    echo "  3) Uninstall (remove all)"
    echo "  4) Dry Run (preview changes)"
    echo ""
    read -p "Choice [1]: " choice
    choice=${choice:-1}
    case $choice in
      1) choice="Install" ;;
      2) choice="Update" ;;
      3) choice="Uninstall" ;;
      4) choice="Dry Run" ;;
    esac
  fi

  case "$choice" in
    *Install*)
      do_install
      ;;
    *Update*)
      do_update
      ;;
    *Uninstall*)
      do_uninstall
      ;;
    *Dry*)
      DRY_RUN=true
      do_install
      ;;
  esac
}

# ============================================================================
# HELP
# ============================================================================

show_help() {
  echo "Dotfiles Manager"
  echo ""
  echo "Usage:"
  echo "  ./bootstrap              Interactive menu"
  echo "  ./bootstrap install      Fresh install"
  echo "  ./bootstrap update       Pull latest + re-apply"
  echo "  ./bootstrap uninstall    Remove all symlinks"
  echo "  ./bootstrap help         Show this help"
  echo ""
  echo "Options:"
  echo "  --dry-run               Show what would be done"
  echo "  --skip-prerequisites    Skip Xcode/Homebrew/gum"
  echo ""
  echo "Examples:"
  echo "  ./bootstrap                      # Show menu"
  echo "  ./bootstrap install --dry-run    # Preview install"
  echo "  ./bootstrap update               # Update dotfiles"
}

# ============================================================================
# MAIN
# ============================================================================

dotfiles_main() {
  local command=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --skip-prerequisites)
        SKIP_PREREQUISITES=true
        shift
        ;;
      install|update|uninstall|help)
        command="$1"
        shift
        ;;
      -*)
        echo "Warning: Unknown option '$1', ignoring"
        shift
        ;;
      *)
        echo "Warning: Unknown argument '$1', ignoring"
        shift
        ;;
    esac
  done

  # Execute command or show menu
  case "$command" in
    install)
      do_install
      ;;
    update)
      do_update
      ;;
    uninstall)
      do_uninstall
      ;;
    help)
      show_help
      ;;
    *)
      show_menu
      ;;
  esac
}
