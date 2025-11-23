#!/bin/bash

set -e

echo "🚀 Installing Neovim..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Minimum required version
MIN_VERSION="0.11.0"

# Check if nvim is already installed and meets minimum version
if command -v nvim &> /dev/null; then
  NVIM_VERSION=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || echo "0.0.0")
  echo "✅ Neovim is already installed: v$NVIM_VERSION"

  # Compare versions (simple numeric comparison for major.minor)
  CURRENT_MAJOR=$(echo "$NVIM_VERSION" | cut -d. -f1)
  CURRENT_MINOR=$(echo "$NVIM_VERSION" | cut -d. -f2)
  MIN_MAJOR=$(echo "$MIN_VERSION" | cut -d. -f1)
  MIN_MINOR=$(echo "$MIN_VERSION" | cut -d. -f2)

  if [ "$CURRENT_MAJOR" -gt "$MIN_MAJOR" ] || \
     ([ "$CURRENT_MAJOR" -eq "$MIN_MAJOR" ] && [ "$CURRENT_MINOR" -ge "$MIN_MINOR" ]); then
    echo "✅ Version meets minimum requirement ($MIN_VERSION)"
  else
    echo "⚠️  Version v$NVIM_VERSION is below minimum requirement ($MIN_VERSION). Upgrading..."
    "$SCRIPT_DIR/install_nvim.sh"
  fi
fi

# Verify installation
if command -v nvim &> /dev/null; then
  NVIM_VERSION=$(nvim --version | head -n 1)
  echo "✅ Neovim successfully installed: $NVIM_VERSION"
else
  echo "❌ Neovim installation failed"
  exit 1
fi

# Setup Neovim dependencies (C compiler for Treesitter)
"$SCRIPT_DIR/setup_nvim_dependencies.sh"

# Setup Neovim configuration
"$SCRIPT_DIR/setup_nvim_config.sh"
