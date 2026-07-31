#!/bin/bash

set -e

echo "🔗 Setting up ripgrep configuration..."

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RIPGREP_CONFIG_SOURCE="$DOTFILES_DIR/configs/ripgrep/ripgreprc"
RIPGREP_CONFIG_DIR="$HOME/.config/ripgrep"
RIPGREP_CONFIG_TARGET="$RIPGREP_CONFIG_DIR/ripgreprc"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)"

mkdir -p "$RIPGREP_CONFIG_DIR"

if [ -e "$RIPGREP_CONFIG_TARGET" ] || [ -L "$RIPGREP_CONFIG_TARGET" ]; then
  if [ -L "$RIPGREP_CONFIG_TARGET" ] && [ "$(readlink "$RIPGREP_CONFIG_TARGET")" == "$RIPGREP_CONFIG_SOURCE" ]; then
    echo "✅ ripgrep config already correctly linked. Skipping."
    exit 0
  else
    echo "📦 Backing up existing ripgrep config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    mv "$RIPGREP_CONFIG_TARGET" "$BACKUP_DIR/"
  fi
fi

echo "🔗 Linking $RIPGREP_CONFIG_SOURCE → $RIPGREP_CONFIG_TARGET"
ln -s "$RIPGREP_CONFIG_SOURCE" "$RIPGREP_CONFIG_TARGET"

echo "✅ ripgrep configuration setup complete!"
