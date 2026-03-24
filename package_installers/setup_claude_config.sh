#!/bin/bash

set -e

echo "🔗 Setting up Claude Code configuration..."

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_CONFIG_SOURCE="$DOTFILES_DIR/configs/claude"
CLAUDE_CONFIG_TARGET="$HOME/.claude"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)"

if [ -e "$CLAUDE_CONFIG_TARGET" ] || [ -L "$CLAUDE_CONFIG_TARGET" ]; then
  if [ -L "$CLAUDE_CONFIG_TARGET" ] && [ "$(readlink "$CLAUDE_CONFIG_TARGET")" == "$CLAUDE_CONFIG_SOURCE" ]; then
    echo "✅ Claude config already correctly linked. Skipping."
    exit 0
  else
    echo "📦 Backing up existing Claude config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    mv "$CLAUDE_CONFIG_TARGET" "$BACKUP_DIR/"
  fi
fi

echo "🔗 Linking $CLAUDE_CONFIG_SOURCE → $CLAUDE_CONFIG_TARGET"
ln -s "$CLAUDE_CONFIG_SOURCE" "$CLAUDE_CONFIG_TARGET"

echo "✅ Claude Code configuration setup complete!"
