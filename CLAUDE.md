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
│   ├── .m8_aliases.sh          # Work-specific Mach8/RallyClaim shortcuts
│   └── my_tools/               # Standalone personal tools (e.g. mind_palace_ritual)
├── configs/            # Application configurations
│   ├── nvim/           # Neovim configuration (see configs/nvim/CLAUDE.md)
│   ├── ripgrep/        # ripgrep config (symlinked to ~/.config/ripgrep/ripgreprc via setup_ripgrep_config.sh)
│   └── ssh/            # SSH client config (symlinked to ~/.ssh/config via setup_ssh_config.sh)
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
- **uv** - Fast Python package and project manager (installed via `package_installers/install_uv.sh`)
- **nvm** - Node.js version management
- **fzf** - Fuzzy finder (installed via `package_installers/install_fzf.sh`)
- **ripgrep** - Fast recursive grep tool (installed via `package_installers/install_ripgrep.sh`, required for Telescope.nvim); config in `configs/ripgrep/ripgreprc` is symlinked to `~/.config/ripgrep/ripgreprc` via `setup_ripgrep_config.sh` and activated by the `RIPGREP_CONFIG_PATH` export in `shared/.shared_environment.sh`. It enables `--hidden` so dotfiles like `shared/.shared_aliases.sh` are searched, and excludes `.git/`.
- **Claude Code** - AI-powered CLI assistant (installed via `package_installers/install_claude_code.sh`); config in `configs/claude/` is symlinked to `~/.claude` via `setup_claude_config.sh`; MCP servers (jira-mach8, jira-arena, datadog-mcp) registered at user scope via `setup_claude_mcp.sh`, so they are available in all projects. Custom subagents live in `configs/claude/agents/`, skills in `configs/claude/skills/` (one directory per skill, containing a `SKILL.md`), and slash commands in `configs/claude/commands/` (one markdown file per command). Skills are also invocable as slash commands (`/skill-name`), so a procedure that a subagent should be able to follow too lives in a skill rather than a command, letting the main session and the subagent run the same instructions. `my-code-review` is the pull request review procedure, followed both by `/my-code-review` in the main session and by the `code-reviewer` agent. A procedure only ever run by hand belongs in `commands/` instead, since a command carries no always-on description and Claude cannot trigger it unprompted. `commands/elaborate.md` walks the user through the code backing a claim Claude made earlier in the same session and declines when the claim was never made there, so it is a command on both counts: it reads the main session's history, which a subagent does not have, and it sets `disable-model-invocation: true` so it fires only when typed. Third-party skills (`teach`, `find-skills`) are vendored from `mattpocock/skills` via `npx skills add`; choose its Copy install method rather than Symlink, since Symlink leaves the content in `~/.agents` outside the repo behind a relative path that only resolves while the repo sits at `~/coding/dotfiles`.
- **GitHub CLI** - GitHub's official command-line tool (installed via `package_installers/install_gh_cli.sh`)
- **colima** - Container runtime for macOS (installed via `package_installers/install_colima.sh`, along with the `docker` client it needs); macOS-only, skipped on Linux where docker runs natively. The `colima-start` alias in `shared/.shared_aliases.sh` starts it with 8GB memory, 6 CPUs and a 100GB disk.
- **SSH config** - Client configuration with host aliases for personal and work GitHub; `setup_ssh_config.sh` keeps `~/.ssh/config` as a real, untracked file whose only content is `Include <repo>/configs/ssh/config`, instead of symlinking it. This is deliberate: `colima start` appends `Include ~/.colima/ssh_config` to `~/.ssh/config`, which used to write straight into the tracked file through the symlink and leave the repository dirty after every start. The script is idempotent, backs up whatever it replaces to `~/dotfiles_backup/`, and prepends the include to an existing `~/.ssh/config` rather than discarding it. Requires SSH keys named `~/.ssh/id_rsa` (personal) and `~/.ssh/mach8_key_rsa` (work) to be present on each machine.
- **mind_palace_practice** - Interactive drill for rehearsing memory material, living in `shared/my_tools/mind_palace_ritual/`. It is a `uv` project (`pyproject.toml` plus `uv.lock`, dependency: `questionary`), and `dotfiles_scripts/mind_palace_practice` is a thin bash wrapper that `setup_mind_palace_practice.sh` symlinks into `~/.local/bin`. The wrapper calls `uv run --project`, so dependencies sync on every invocation and no environment is activated by hand. The first menu picks a **subject** (Mind palaces or Major system), the second picks a **deck** inside it, the third narrows the deck to a **range** of cards when the deck offers ranges, then ritual and mode follow as before; a menu with a single option is skipped, which is why the major system currently jumps straight from the subject to the range question. Everything below the menus practices one `Deck` of `PracticeCard`s (`cards.py`): a card is a number, a name, and an optional place, so palaces and the major system share the rituals, modes, session loop, scoreboard and leaderboard rather than duplicating them. `subjects.py` is the only place that knows how a palace or a major system turns into a deck. Ranges are grouped: a deck carries `RangeGroup`s, each a named way of slicing it with its own question and its own `CardRange`s. A deck with one group asks a single question that lists All plus that group's ranges, while a deck with several asks "How much do you want to practice?" first (All, or the name of a group) and then the chosen group's question, which keeps a palace with eight rooms from turning into one seventeen entry menu. A major system deck has one group of cumulative `CardRange`s that grow one block of ten at a time (`01-10` through `01-90`, and `001-100` through `001-900` for a three digit map), so you can drill everything learned so far instead of all 100; picking a range returns a deck narrowed to those cards whose name gains the range label, which is what gives `01-30` its own leaderboard instead of sharing the hundred card board with the full run. Picking All leaves the deck untouched, so the full run keeps the plain deck name. A palace has two groups instead, both built from its rooms in `subjects.py`: **Up to room** runs from object 1 to the end of the chosen room (`Maze up to Picnic`), and **Room** practices that room alone (`Maze Druid place only`). Up to room omits the last room, since that run is All. Object numbers stay the palace wide positions, so a single room deck asks for numbers 16 to 20 rather than renumbering from 1, and each room slice earns its own leaderboard through the same narrowed deck name. A palace of one room declares no groups and skips the menu. Extension points: each palace is one module in `mind_palace_ritual/resources/mind_palaces/` exposing a single `mind_palace` variable, and each major system map is one module in `mind_palace_ritual/resources/major_system/` exposing a single `major_system` variable (`two_digits.py` maps `"01"`-`"99"` plus `"00"` to a word); both are discovered at runtime by `catalog.py`, so adding either means adding a file and nothing else. Rituals and modes are Protocol implementations returned by `available_rituals()` and `available_modes()`, and a mode declares `records_best_times` to say whether finishing it earns a leaderboard entry. Ritual names are built from the deck's `card_noun`, so a palace offers "Number to object" and "Object to number" while the major system offers "Number to word" and "Word to number", and the palace boards recorded before the major system existed keep their names. Object numbers are not stored in the palace data, they are the object's sequential position across the palace, walking rooms in order and starting at 1; major system numbers are the map keys, kept as strings so `"04"` stays two digits, and they are ordered with `"00"` last so a deck runs `01` through `99` and ends on `00` as if it were 100. Answers are graded by `Question.judge()` into `CORRECT`, `MISSPELLED` or `WRONG` (`rituals.py`). A misspelled answer counts as correct, it does not add a wrong attempt, but the right spelling is printed before moving on. The tolerance is Levenshtein distance in `spelling.py`, scaled to the expected answer so a 1-3 character answer allows no slips, 4-6 characters allow one and 7 or more allow two, and it applies only when the expected answer is a name: number answers stay exact, since `43` for `42` is one edit away but a different card. Three wrong answers in a row on one question end it: `session.py` reveals the card and moves on to the next target instead of asking again, which keeps one forgotten card from stalling the run in any mode or ritual. The card is not finished though, it goes back into the deck: a mode returns a `PracticeTargets` object (`modes.py`) with a `put_back` method, and Complete mode's `EveryCardOnce` reinserts the card at a random position among the cards still pending, so a Complete run ends only once every card has actually been answered and the same card can be revealed and reinserted several times. Endless mode ignores `put_back`, since its random draw brings the card round again anyway. A card that comes back does not open a second entry on the scoreboard: `session.py` calls `Scoreboard.add_wrong_attempts` rather than `record`, so the attempts from every pass pile onto one `CardResult`, Cards practiced still equals the deck size, and the card counts as not correct on the first try. Every one of those attempts counts as a wrong attempt in the summary and on the leaderboard, and a Complete run that revealed cards still finishes the deck and is still recorded. Best times are kept in `mind_palace_ritual/practice_records/`, which **is committed** so the boards follow the repo across machines. It is a directory rather than a single file on purpose: every recorded run is its own small JSON file, named after the board plus a microsecond timestamp, so two machines recording runs before either pulls create different files instead of conflicting edits to one. Records are stored, read and deleted by `record_files.py`, which knows about paths and file names and nothing else; `records.py` holds the plain types (`BoardKey`, `TimedRun`, `Placement`) and the ranking rule; `record_book.py` joins the two, and is the only place that decides what a new run means for a board. Each board holds the 10 fastest runs for one (deck, card count, ritual) triple: the card count is part of the key so growing a palace starts a fresh board rather than mixing runs of different lengths, and the ritual is part of it because typing a number is far faster than typing a word. A run that does not reach the top ten writes no file at all, and showing a board prunes it: the files of runs that the new run pushed out are deleted then, which is the only time a board can go stale, so no separate cleanup pass is needed. Ties in seconds are broken by the timestamp, so the board reads the same on every machine. Only a run finished to the end in Complete mode is recorded, never an interrupted or Endless one.

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
