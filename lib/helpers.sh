#!/bin/zsh

# ============================================================================
# DOTFILES HELPERS
# ============================================================================
# Common functions used across dotfiles scripts
# ============================================================================

# Colors (fallback when gum is not available)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# DETECTION
# ============================================================================

has_gum() { command -v gum &> /dev/null; }

# ============================================================================
# PRINTING
# ============================================================================

print_header() {
  local title="${1:-Dotfiles}"
  local color="${2:-212}"
  echo ""
  if has_gum; then
    gum style --foreground "$color" --border-foreground "$color" --border double \
      --align center --width 50 --margin "1 2" --padding "1 4" \
      "$title"
  else
    echo -e "${BOLD}================================${NC}"
    echo -e "${BOLD}    $title${NC}"
    echo -e "${BOLD}================================${NC}"
  fi
  echo ""
}

print_step() {
  if has_gum; then
    gum style --foreground 39 -- "-> $1"
  else
    echo -e "${BLUE}->${NC} $1"
  fi
}

print_success() {
  if has_gum; then
    gum style --foreground 82 -- "[ok] $1"
  else
    echo -e "${GREEN}[ok]${NC} $1"
  fi
}

print_warning() {
  if has_gum; then
    gum style --foreground 214 -- "[!] $1"
  else
    echo -e "${YELLOW}[!]${NC} $1"
  fi
}

print_error() {
  if has_gum; then
    gum style --foreground 196 -- "[x] $1"
  else
    echo -e "${RED}[x]${NC} $1"
  fi
}

# ============================================================================
# DRY-RUN SUPPORT
# ============================================================================

# Dry-run wrapper - executes command or prints what would be done
run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

# Dry-run aware symlink (with source file existence check and target safety)
dry_ln() {
  local src="$1"
  local dst="$2"

  # Check if source exists (file or directory)
  if [ ! -e "$src" ]; then
    print_warning "Source does not exist: $src"
    return 1
  fi

  # If target already points to src, nothing to do (strict idempotency)
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return 0
  fi

  # If target is a regular file or directory (not a symlink), back it up once
  # to avoid silent data loss
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local backup="$dst.backup"
    if [ ! -e "$backup" ]; then
      if [[ "$DRY_RUN" == "true" ]]; then
        echo "[dry-run] cp -R \"$dst\" \"$backup\"  # backing up non-symlink target"
      else
        cp -R "$dst" "$backup" 2>/dev/null && \
          print_warning "Backed up existing file: $backup"
      fi
    else
      print_warning "Target exists (and .backup already present): $dst"
    fi
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] ln -sf \"$src\" \"$dst\""
  else
    ln -sf "$src" "$dst"
  fi
}

# Dry-run aware mkdir
dry_mkdir() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] mkdir -p \"$1\""
  else
    mkdir -p "$1"
  fi
}

# Dry-run aware rm
dry_rm() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] rm -f \"$1\""
  else
    rm -f "$1"
  fi
}

# Run with spinner (or plain output in dry-run/no-gum mode)
run_with_spinner() {
  local title="$1"
  shift
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] $*"
  elif has_gum; then
    gum spin --spinner dot --title "$title" -- "$@"
  else
    echo "$title"
    "$@"
  fi
}
