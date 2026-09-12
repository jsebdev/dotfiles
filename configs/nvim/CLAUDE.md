# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Neovim configuration based on kickstart.nvim with extensive personal customizations. It's a Lua-based configuration that extends the kickstart foundation with custom plugins, keybindings, utilities, and development workflows.

## Key Commands

### Plugin Management
- `:Lazy` - View and manage installed plugins
- `:Lazy update` - Update all plugins
- `:Mason` - View and install LSP servers, formatters, and linters
- `:Tutor` - Run Neovim's built-in tutorial

### Development Commands
- `nvim` - Start Neovim with this configuration
- `:checkhealth` - Check configuration health and dependencies

## Architecture

### Core Structure
- `init.lua` - Main configuration entry point that loads kickstart.nvim base and custom configurations
- `lazy-lock.json` - Lock file for plugin versions (should be tracked in version control). `:Lazy update` rewrites it with whatever that machine just installed, so a machine that updates while another one lags will commit the lock backwards and silently downgrade the other. To sync a second machine, pull and run `:Lazy restore`, which checks out the committed commits, rather than `:Lazy update`.

### Custom Configuration (`lua/custom/`)
- `global_state.lua` - Global state management (loaded first)
- `keymaps.lua` - Personal keybindings and shortcuts
- `options.lua` - Neovim options and settings
- `plugins/init.lua` - Custom plugin specifications
- `plugin_config/` - Plugin-specific configuration modules
- `utils/` - Custom utility functions and helpers
- `autocmds/` - Custom autocommands

### Key Custom Utilities
- `smart_windows_close.lua` - Intelligent window/tab closing with buffer tracking
- `toggle_terminal.lua` - Terminal management across different layouts
- `smart_print.lua` - Language-specific debug printing helpers
- `lsp_def_in_new_tab_or_references.lua` - Enhanced LSP navigation
- `telescope.lua` - Extended telescope configuration with custom searches

### Plugin Ecosystem
The configuration uses lazy.nvim as plugin manager with these key additions beyond kickstart:
- **null-ls/none-ls** - Formatters and linters (prettier, stylua, ruff, eslint)
- **avante.nvim** - AI coding assistant with Claude provider
- **copilot.vim** - GitHub Copilot integration
- **haskell-tools.nvim** - Enhanced Haskell development
- **go.nvim** - Comprehensive Go development tooling
- **git-blame.nvim** - Git blame information
- **diffview.nvim** - Multi-file diff review and file history, lazy loaded on `:DiffviewOpen`/`:DiffviewFileHistory` and the `<leader>g*` keys
- **Various utilities** - autoclose, emmet, spell checking, file operations

### LSP Configuration
Language servers live in the `servers` table inside the `nvim-lspconfig` spec in `init.lua`. Each entry is registered with `vim.lsp.config(name, config)` and turned on with `vim.lsp.enable`, the Neovim 0.11 native API. Do **not** go back to `require('lspconfig')[name].setup()`: nvim-lspconfig deprecated that framework in September 2025 and prints a startup traceback on every newer version, and it disappears in nvim-lspconfig v3.0.0.

- Shared capabilities (nvim-cmp, lsp-file-operations) are registered once through `vim.lsp.config('*', { capabilities = capabilities })` and merge into every server, so individual entries only declare what they override.
- Each entry merges on top of the defaults nvim-lspconfig ships in its `lsp/<server>.lua`, so an entry only needs the differences.
- `mason-lspconfig` is still set up, but without `handlers`. It stays because `mason-tool-installer` uses its name mappings to translate lspconfig server names into Mason package names. Dropping it would break `ensure_installed`.
- Bypassing lspconfig's `setup()` also bypasses mason-lspconfig's `util.on_setup` hook, which is what used to register the `:PylspInstall` command. Mason prepends its `bin` directory to `PATH`, so server executables are still found.
- **This requires Neovim 0.11 or newer on every machine that uses this config.**

### Language Support
Configured for:
- **TypeScript/JavaScript** - ts_ls, eslint, prettier
- **Python** - basedpyright, pylsp with flake8, ruff formatting
- **Lua** - lua_ls, stylua formatting
- **HTML/CSS** - emmet support, auto-tagging
- **Haskell** - haskell-tools integration
- **Go** - gopls LSP, go.nvim with test runner, code generation, formatting on save
- **C/C++** - clangd support

### Key Custom Keybindings
- **Leader key**: `<space>`
- **Tab navigation**: `<C-j>/<C-k>` for tab switching
- **Window management**: `<leader>w*` prefix for splits, resize, etc.
- **Terminal**: `<Alt-t>*` for various terminal layouts
- **Smart utilities**: `<leader>z*` for debug printing, `<leader>y*` for copying paths
- **Formatting**: `=` for LSP formatting
- **AI assistance**: `<leader>ae` for Avante commands
- **Git diffs**: `<leader>g*` for diffview (`gd` working tree, `gm` vs main, `gh` file history, `gq` close)

### Telescope Integration
Extensive telescope configuration with:
- Hidden file search enabled
- Custom grep patterns for different file types
- Vertical layout optimized for large screens
- Custom searches for Python/TypeScript files specifically

### Development Workflow
- Treesitter for syntax highlighting with comprehensive language support
- LSP integration with Mason for automatic tool installation
- Spell checking enabled by default
- Custom folding with treesitter expressions
- Global state tracking for closed buffers and smart reopening

## Important Notes

- Configuration loads global_state before other custom configs
- Keybindings are loaded last to ensure proper Capital key mapping
- Uses vertical telescope layout optimized for large screens
- Spell checking is enabled globally
- Custom color scheme modifications for better contrast