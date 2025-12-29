# Dotfiles

Personal macOS development environment.

## Quick Start

### Prerequisites

Install these **before** running bootstrap:

1. **Xcode Command Line Tools**

   ```bash
   xcode-select --install
   ```

2. **Homebrew**

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Restart your terminal** (only needed if you just installed Homebrew)

### New Machine

```bash
curl -fsSL https://raw.githubusercontent.com/rafaelcruzazevedo/dotfiles/master/bootstrap | zsh
```

### Existing Machine

```bash
cd ~/.dotfiles
./bootstrap
```

This shows an interactive menu:

```text
> Install (fresh setup)
  Update (pull + re-apply)
  Uninstall (remove all)
  Dry Run (preview changes)
```

### Command Line

```bash
./bootstrap install           # Fresh install
./bootstrap update            # Pull + re-apply
./bootstrap uninstall         # Remove all
./bootstrap install --dry-run # Preview changes
./bootstrap help              # Show help
```

## Troubleshooting

### Icons not displaying

```bash
brew install font-meslo-lg-nerd-font
```

Set font in iTerm2: **Preferences > Profiles > Text**

### Starship prompt not showing

```bash
brew install starship
```

### fzf key bindings not working

```bash
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
```

### zplug plugins not loading

```bash
zplug install && zplug load
```

---

[Full documentation](DOCS.md) | MIT License
