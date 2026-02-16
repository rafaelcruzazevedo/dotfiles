# Dotfiles (Linux)

Personal Linux/VPS development environment.

## Quick Start

### New Machine

```bash
curl -fsSL https://raw.githubusercontent.com/rafazsh/dotfiles/linux/bootstrap | bash
```

No prerequisites — the bootstrap installs everything (system packages, Homebrew, tools).

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

### Starship prompt not showing

```bash
brew install starship
```

### fzf key bindings not working

On root/VPS setups where Homebrew runs under a `linuxbrew` user:

```bash
/home/linuxbrew/.linuxbrew/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
```

Otherwise:

```bash
$(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
```

### zplug plugins not loading

```bash
zplug install && zplug load
```

---

[Full documentation](DOCS.md) | MIT License
