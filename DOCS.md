# Documentation

## Features

- **Starship** - Fast, cross-shell prompt written in Rust
- **Modern CLI tools** - eza, bat, fd, ripgrep, zoxide, fzf
- **zplug** - Minimal Zsh plugin manager
- **iTerm2** - Terminal with Dynamic Profiles and Shell Integration
- **Cursor/VSCode** - Editor configuration with extensions and MCP servers
- **AI tools** - Claude Code (rules, skills, plans, plugins)
- **DevOps** - AWS SSO, Terraform, kubectl, Docker, Atlassian CLI

## Prerequisites

Before running bootstrap, install these manually:

### 1. Xcode Command Line Tools

```bash
xcode-select --install
```

Complete the installation dialog when prompted.

### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Important**: Restart your terminal after installing Homebrew to ensure the PATH is updated.

### Why Manual Prerequisites?

- **Reliability**: Homebrew's PATH setup requires a shell restart to work correctly
- **Control**: You know exactly what's being installed before running bootstrap
- **Error visibility**: Separate installation makes troubleshooting easier

## What's Installed

### Brew Packages

See [`Brewfile`](Brewfile) for the complete list including:

- Development tools (git, gh, docker, etc.)
- Languages & runtimes (Node.js via Volta, Python, Java, Bun)
- DevOps tools (AWS CLI, Terraform, kubectl, k9s)
- Modern CLI replacements (eza, bat, fd, ripgrep, zoxide, fzf)
- AI tools (Claude Code, Cursor)
- Atlassian CLI (acli)
- Monitoring (sentry-cli)
- Secrets management (1password-cli)

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
│   ├── .gitaliases
│   └── utils/
│       ├── git-commit-lost.sh
│       └── git-status-plus.sh
├── apps/                     # App configs
│   ├── cursor/
│   │   ├── settings.json
│   │   ├── keybindings.json
│   │   ├── mcp.json          # MCP servers config
│   │   └── extensions.txt
│   ├── claude/
│   │   ├── settings.json
│   │   ├── rules/            # Claude Code Rules
│   │   ├── skills/           # Claude Code Skills
│   │   ├── plans/            # Claude Code Plans
│   │   └── plugins/          # Claude Code Plugins config
│   └── iterm/
│       ├── defaults
│       └── profiles/default.json
├── macos/
│   └── defaults
└── Brewfile
```

## Claude Code layout

The `apps/claude/` tree uses two different strategies depending on whether
Claude writes to the file at runtime:

| Path | Strategy | Rationale |
|------|----------|-----------|
| `apps/claude/settings.json` | symlink | Authored config — edits in repo apply immediately |
| `apps/claude/rules/*.md` | symlink (per file) | Authored rules — edits propagate |
| `apps/claude/skills/*/` | symlink (per directory) | Authored skills — edits propagate |
| `apps/claude/ccstatusline.json` | symlink | Status line config referenced from `settings.json` |
| `apps/claude/plans/` | seed-only | Claude writes here at runtime; repo only seeds empty state |
| `apps/claude/plugins/known_marketplaces.json` | seed-only | Portable marketplace list; Claude manages install state separately |

`installed_plugins.json` is intentionally **not** tracked — it contains
absolute paths and cache locations that differ per machine.

### Adding a Claude skill

```bash
cd apps/claude/skills
mkdir my-skill
cat > my-skill/SKILL.md <<'EOF'
---
name: my-skill
description: What the skill does
---

# My Skill

...
EOF

# Re-run install to create the symlink
./bootstrap install
```

## Extending

Add personal configurations to local files (not versioned):

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Shell secrets, custom aliases, API keys |
| `~/.gitconfig.local` | Git user config, signing keys |
| `~/.vimrc.local` | Personal Vim settings |

### Example `.zshrc.local`

See [`shell/.zshrc.local.example`](shell/.zshrc.local.example) for the full template with documentation links.

```bash
# AWS (use SSO - recommended)
export AWS_PROFILE="dev-admin"

# AI Services
export ANTHROPIC_API_KEY="..."
export OPENAI_API_KEY="..."

# Development
export GITHUB_PERSONAL_ACCESS_TOKEN="..."

# Monitoring
export SENTRY_AUTH_TOKEN="..."
export SENTRY_ORG="..."

# Productivity (for MCP servers)
export NOTION_API_KEY="..."
```

## Authentication

### Browser-based (recommended)

| Tool | Command | Documentation |
|------|---------|---------------|
| AWS CLI | `aws configure sso` | [AWS SSO](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) |
| GitHub CLI | `gh auth login` | [GitHub CLI](https://cli.github.com/manual/gh_auth_login) |
| Atlassian CLI | `acli login` | [Atlassian CLI](https://developer.atlassian.com/cloud/acli/) |
| Docker | `docker login` | [Docker Hub](https://hub.docker.com/) |
| 1Password CLI | `op signin` | [1Password Dev](https://developer.1password.com/docs/cli/) |

### API Key (env var)

| Tool | Variable | Documentation |
|------|----------|---------------|
| Claude Code | `ANTHROPIC_API_KEY` | [Anthropic Console](https://console.anthropic.com/settings/keys) |
| DigitalOcean | `DIGITALOCEAN_ACCESS_TOKEN` | [DO Docs](https://docs.digitalocean.com/reference/api/create-personal-access-token/) |
| Sentry CLI | `SENTRY_AUTH_TOKEN` | [Sentry Docs](https://docs.sentry.io/product/cli/configuration/) |
| GitHub MCP | `GITHUB_PERSONAL_ACCESS_TOKEN` | [GitHub Tokens](https://github.com/settings/tokens) |
| Notion MCP | `NOTION_API_KEY` | [Notion Integrations](https://www.notion.so/my-integrations) |

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
