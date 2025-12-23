# Documentation

## Features

- **Starship** - Fast, cross-shell prompt written in Rust
- **Modern CLI tools** - eza, bat, fd, ripgrep, zoxide, fzf
- **zplug** - Minimal Zsh plugin manager
- **iTerm2** - Terminal with Dynamic Profiles and Shell Integration
- **Cursor/VSCode** - Editor configuration with extensions

## What's Installed

### Brew Packages

See [`Brewfile`](Brewfile) for the complete list including:

- Development tools (git, gh, docker, etc.)
- Languages & runtimes (Node.js via Volta, Python, Java, Bun)
- DevOps tools (AWS CLI, Terraform, kubectl, k9s)
- Modern CLI replacements (eza, bat, fd, ripgrep, zoxide, fzf)

### Shell Configuration

| File | Description |
|------|-------------|
| `.zshrc` | Main shell configuration |
| `.zshrc.local` | Personal secrets (not versioned) |
| `starship.toml` | Prompt configuration |

### iTerm2

- Dynamic Profile with P3 color space
- Unlimited scrollback
- Shell Integration for command navigation
- Nerd Font support (MesloLGS NF)

## Directory Structure

```
dotfiles/
├── bootstrap                 # Entry point (new machine + existing machine)
├── lib/                      # Shared functions
│   ├── main.sh               # Menu, help, argument parsing
│   ├── helpers.sh            # UI functions
│   ├── install.sh            # Install/update functions
│   └── uninstall.sh          # Uninstall functions
├── shell/                    # Shell configs
│   ├── .zshrc
│   ├── .vimrc
│   ├── .zshrc.local.example
│   └── starship.toml
├── git/                      # Git configs
│   ├── .gitconfig
│   └── utils/
│       ├── git-commit-lost.sh
│       └── git-status-plus.sh
├── apps/                     # App configs
│   ├── cursor/
│   │   ├── settings.json
│   │   ├── keybindings.json
│   │   └── extensions.txt
│   └── iterm/
│       ├── defaults
│       └── profiles/default.json
├── macos/
│   └── defaults
└── Brewfile
```

## Extending

Add personal configurations to local files (not versioned):

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Shell secrets, custom aliases, API keys |
| `~/.gitconfig.local` | Git user config, signing keys |
| `~/.vimrc.local` | Personal Vim settings |

### Example `.zshrc.local`

```bash
# API Keys
export GITHUB_PERSONAL_ACCESS_TOKEN="..."
export FIGMA_API_KEY="..."

# Custom aliases
alias myproject="cd ~/Projects/myproject"
```

## Modern CLI Tools

| Command | Replacement | Description |
|---------|-------------|-------------|
| `ls` | `eza` | List files with icons and git status |
| `ll` | `eza -la` | Long list with details |
| `cat` | `bat` | Syntax highlighting and git diff |
| `cd` | `z` (zoxide) | Smart directory jumping |
| `cdi` | `zi` | Interactive directory picker |
| `tree` | `eza --tree` | Tree view with icons |

## Bootstrap Flow

The `bootstrap` script is the single entry point. It detects whether dotfiles are already installed:

### New Machine (via curl | bash)

1. **Installs Xcode CLT** - Required for git and compilers
2. **Installs Homebrew** - Package manager for macOS
3. **Installs gum** - For beautiful terminal UI
4. **Sets up SSH** - Generates ed25519 key for GitHub
5. **Clones dotfiles** - To `~/.dotfiles`
6. **Runs install** - Installs everything else

### Existing Machine (./bootstrap)

Shows interactive menu or accepts subcommands:
- `./bootstrap` - Interactive menu
- `./bootstrap install` - Fresh install
- `./bootstrap update` - Pull + re-apply
- `./bootstrap uninstall` - Remove all

### Install

The install command:

1. Installs Homebrew packages from `Brewfile`
2. Creates symlinks for shell configs
3. Configures Starship prompt
4. Sets up fzf key bindings
5. Configures iTerm2 with Dynamic Profiles
6. Applies macOS defaults
7. Configures Cursor/VSCode (optional)

### Update

The update command:

1. Stashes local changes (if any)
2. Pulls latest from remote
3. Re-runs install (skipping prerequisites)

### Uninstall

The uninstall command:

1. Removes all symlinks
2. Optionally removes `~/.dotfiles` directory
3. Leaves Homebrew packages intact

## Troubleshooting

### iTerm2 Shell Integration

If Shell Integration didn't install automatically:

```bash
curl -fsSL https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
```

Or install via iTerm2 menu: **iTerm2 > Install Shell Integration**

### zoxide not jumping to directories

Initialize the database by visiting directories:

```bash
cd ~/Projects
cd ~/Documents
# zoxide learns from your navigation
```

Then use `z projects` to jump back.
