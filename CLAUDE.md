# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL: Maintaining This Documentation

**When making ANY changes to this repository, you MUST update this CLAUDE.md file if the changes affect its content.** This includes:
- Modifying shell configurations (.bashrc, .zshrc, or any shared files)
- Changing the installation process or directory structure
- Adding/removing package installers
- Modifying work-specific tooling

**This is not optional.** The documentation must stay synchronized with the code. Update relevant sections immediately after making changes, even if they seem minor.

## Repository Overview

This is a personal dotfiles repository that manages shell configurations, application settings, and development environment setup using a **symlink-based installation approach**. The repository is designed to be shell-agnostic at its core, with support for both bash and zsh through a modular loading system.

### Design Philosophy
- Shell-agnostic core functionality with shell-specific customizations
- Shared functions and aliases to reduce duplication
- Automated installation via bootstrap script
- Secrets excluded from version control (`.gitignore` excludes `*secrets` pattern)
- **Linux package management**: All Linux installers assume `apt-get` (Debian/Ubuntu-based distributions). Other package managers (dnf, yum, pacman) are not supported.

## Installation

### Quick Start
```bash
./install.sh
```

The installation script:
1. Detects your current shell (zsh or bash)
2. Creates timestamped backups at `~/dotfiles_backup/YYYY-MM-DD_HH-MM-SS/`
3. Symlinks configuration files from the repository to your home directory
4. Runs package installers

### Manual Steps
- **Secrets files**: Create `.zsh_secrets.sh` or `.bash_secrets.sh` for API keys and sensitive data (git-ignored)

## Directory Structure

```
dotfiles/
├── bash/               # Bash-specific configurations (.bashrc, .bash_aliases.sh)
├── zsh/                # Zsh-specific configurations (.zshrc, .zsh_aliases.sh)
├── shared/             # Shared configurations between shells
│   ├── .dotfiles_utils.sh      # Core utility (load_if_exists function)
│   ├── .dotfiles_shared.sh     # Orchestrator that loads other shared files
│   ├── .shared_aliases.sh      # Common aliases
│   ├── .shared_functions.sh    # Common functions
│   └── .m8_aliases.sh          # Work-specific Mach8/RallyClaim shortcuts
├── configs/            # Application configurations
│   └── nvim/           # Neovim configuration (see configs/nvim/CLAUDE.md)
├── package_installers/ # Installation scripts for tools (e.g., install_fzf.sh)
├── ignored/            # Git-ignored personal notes
├── .gitconfig          # Git configuration
└── .tmux.conf          # Tmux configuration
```

## Configuration Loading Hierarchy

Shell configuration files load in this order:

```
~/.zshrc or ~/.bashrc (shell entry point)
    ↓
~/.dotfiles_utils.sh (provides load_if_exists utility)
    ↓
~/.dotfiles_shared.sh (orchestrator)
    ↓
├── ~/.shared_aliases.sh
├── ~/.shared_functions.sh
└── ~/.m8_aliases.sh
    ↓
Shell-specific files (~/.zsh_aliases.sh or ~/.bash_aliases.sh)
    ↓
Secrets file (~/.zsh_secrets.sh or ~/.bash_secrets.sh, optional)
```

The `load_if_exists` function (from `.dotfiles_utils.sh`) safely sources files and warns if they're missing.

## Common Commands and Workflows

### Development Environment Setup
The repository integrates these version managers and tools:
- **tmux** - Terminal multiplexer (installed via `package_installers/install_tmux.sh`)
- **unzip** - Archive extraction utility (installed via `package_installers/install_unzip.sh`, required for Mason.nvim package installations)
- **miniconda** - Minimal Python distribution and package manager (installed via `package_installers/install_miniconda.sh`)
- **AWS CLI** - Amazon Web Services command-line interface (installed via `package_installers/install_aws_cli.sh`)
- **pyenv** - Python version management (initialized in both shells)
- **nvm** - Node.js version management
- **fzf** - Fuzzy finder (installed via `package_installers/install_fzf.sh`)
- **ripgrep** - Fast recursive grep tool (installed via `package_installers/install_ripgrep.sh`, required for Telescope.nvim)
- **Claude Code** - AI-powered CLI assistant (installed via `package_installers/install_claude_code.sh`); config in `configs/claude/` is symlinked to `~/.claude` via `setup_claude_config.sh`

## Shell-Specific Features

### Bash (`bash/.bashrc`)
- Extensive history configuration
- SSH agent auto-start
- Volition staging DB SSH port forwarding (`volition_toggle_staging_db_forwarding`)
- Cargo (Rust) environment setup
- Terraform completion

### Zsh (`zsh/.zshrc`)
- LLVM toolchain paths (Homebrew)
- PostgreSQL multiple versions support
- MQL5 MetaTrader integration
- GHCup (Haskell) environment setup
- Zed editor shortcut (`zed` alias)
- Second brain directory shortcut

## Customization Guidelines

### Adding New Aliases
- **Shared between shells**: Add to `shared/.shared_aliases.sh`
- **Shell-specific**: Add to `bash/.bash_aliases.sh` or `zsh/.zsh_aliases.sh`
- **Work-related**: Add to `shared/.m8_aliases.sh`

### Adding New Functions
- **Shared functions**: Add to `shared/.shared_functions.sh`
- **Shell-specific functions**: Add to shell-specific `.bashrc` or `.zshrc`

### Adding Secrets
Create a `.zsh_secrets.sh` or `.bash_secrets.sh` file in the respective shell directory (these are git-ignored). Export environment variables there:
```bash
export OPENAI_API_KEY="your-key-here"
export ANTHROPIC_API_KEY="your-key-here"
```

## Package Installers

The `package_installers/` directory contains idempotent installation scripts for tools. All installers:
- Check if the tool is already installed before attempting installation
- Use `apt-get` for Linux package management
- Support macOS via Homebrew where applicable
- Are called sequentially by `install.sh`

To add new installers, create similar scripts and call them from `install.sh`.

## Git Configuration

`.gitconfig` includes:
- Custom log aliases (`logad`, `logadu`, `logd`, `logdu`) for pretty-printed git history
- Git LFS configuration
- Neovim as default editor
- Case-sensitive file handling

## Neovim Configuration

The Neovim configuration in `configs/nvim/` is extensive (1032-line `init.lua` based on kickstart.nvim). See `configs/nvim/CLAUDE.md` for detailed documentation about:
- Plugin ecosystem (lazy.nvim, LSP, Telescope, Treesitter)
- AI integrations (avante.nvim with Claude, GitHub Copilot)
- Language support and custom utilities

## Important Notes

- The installation script is **idempotent** - it skips relinking files that are already correctly symlinked
- Backups are only created for files that differ from the source
- The repository uses `set -e` in scripts to fail fast on errors
- Missing optional files (like secrets) are skipped with warnings
