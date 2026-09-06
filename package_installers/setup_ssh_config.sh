#!/bin/bash

set -e

echo "🔗 Setting up SSH configuration..."

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SSH_CONFIG_SOURCE="$DOTFILES_DIR/configs/ssh/config"
SSH_DIR="$HOME/.ssh"
SSH_CONFIG_TARGET="$SSH_DIR/config"
INCLUDE_LINE="Include $SSH_CONFIG_SOURCE"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -L "$SSH_CONFIG_TARGET" ]; then
  echo "📦 Backing up symlinked SSH config to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  mv "$SSH_CONFIG_TARGET" "$BACKUP_DIR/"
fi

if [ ! -e "$SSH_CONFIG_TARGET" ]; then
  echo "📄 Creating $SSH_CONFIG_TARGET"
  printf '%s\n' "$INCLUDE_LINE" > "$SSH_CONFIG_TARGET"
  chmod 600 "$SSH_CONFIG_TARGET"
  echo "✅ SSH configuration setup complete!"
  exit 0
fi

if grep -qxF "$INCLUDE_LINE" "$SSH_CONFIG_TARGET"; then
  echo "✅ SSH config already includes the dotfiles config. Skipping."
  exit 0
fi

echo "📦 Backing up existing SSH config to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
cp "$SSH_CONFIG_TARGET" "$BACKUP_DIR/"

echo "➕ Adding dotfiles include to $SSH_CONFIG_TARGET"
printf '%s\n\n%s\n' "$INCLUDE_LINE" "$(cat "$SSH_CONFIG_TARGET")" > "$SSH_CONFIG_TARGET.dotfiles_tmp"
mv "$SSH_CONFIG_TARGET.dotfiles_tmp" "$SSH_CONFIG_TARGET"
chmod 600 "$SSH_CONFIG_TARGET"

echo "✅ SSH configuration setup complete!"
