#!/bin/bash

set -e

echo "🔗 Setting up Neovim configuration..."

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NVIM_CONFIG_SOURCE="$DOTFILES_DIR/configs/nvim"
NVIM_CONFIG_TARGET="$HOME/.config/nvim"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)"

if [ -e "$NVIM_CONFIG_TARGET" ] || [ -L "$NVIM_CONFIG_TARGET" ]; then
  if [ -L "$NVIM_CONFIG_TARGET" ] && [ "$(readlink "$NVIM_CONFIG_TARGET")" == "$NVIM_CONFIG_SOURCE" ]; then
    echo "✅ Neovim config already correctly linked. Skipping."
    exit 0
  else
    echo "📦 Backing up existing Neovim config to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    mv "$NVIM_CONFIG_TARGET" "$BACKUP_DIR/"
  fi
fi

mkdir -p "$HOME/.config"
echo "🔗 Linking $NVIM_CONFIG_SOURCE → $NVIM_CONFIG_TARGET"
ln -s "$NVIM_CONFIG_SOURCE" "$NVIM_CONFIG_TARGET"

echo "✅ Neovim configuration setup complete!"
