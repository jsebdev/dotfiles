#!/bin/bash

set -e

echo "🔗 Setting up gh configuration..."

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GH_CONFIG_SOURCE="$DOTFILES_DIR/configs/gh/config.yml"
GH_CONFIG_DIR="$HOME/.config/gh"
GH_CONFIG_TARGET="$GH_CONFIG_DIR/config.yml"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)"

mkdir -p "$GH_CONFIG_DIR"

if [ -e "$GH_CONFIG_TARGET" ] || [ -L "$GH_CONFIG_TARGET" ]; then
  if [ -L "$GH_CONFIG_TARGET" ] && [ "$(readlink "$GH_CONFIG_TARGET")" == "$GH_CONFIG_SOURCE" ]; then
    echo "✅ gh config already correctly linked. Skipping."
    exit 0
  else
    echo "📦 Backing up existing gh config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    mv "$GH_CONFIG_TARGET" "$BACKUP_DIR/"
  fi
fi

echo "🔗 Linking $GH_CONFIG_SOURCE → $GH_CONFIG_TARGET"
ln -s "$GH_CONFIG_SOURCE" "$GH_CONFIG_TARGET"

echo "✅ gh configuration setup complete!"
