#!/bin/bash

set -e

echo "🔗 Setting up SSH configuration..."

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SSH_CONFIG_SOURCE="$DOTFILES_DIR/configs/ssh/config"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG_TARGET="$SSH_DIR/config"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -e "$SSH_CONFIG_TARGET" ] || [ -L "$SSH_CONFIG_TARGET" ]; then
  if [ -L "$SSH_CONFIG_TARGET" ] && [ "$(readlink "$SSH_CONFIG_TARGET")" == "$SSH_CONFIG_SOURCE" ]; then
    echo "✅ SSH config already correctly linked. Skipping."
    exit 0
  else
    echo "📦 Backing up existing SSH config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    mv "$SSH_CONFIG_TARGET" "$BACKUP_DIR/"
  fi
fi

echo "🔗 Linking $SSH_CONFIG_SOURCE → $SSH_CONFIG_TARGET"
ln -s "$SSH_CONFIG_SOURCE" "$SSH_CONFIG_TARGET"

echo "✅ SSH configuration setup complete!"
