#!/bin/bash

set -e

echo "🚀 Installing Neovim..."

# Check if nvim is already installed
if command -v nvim &> /dev/null; then
  NVIM_VERSION=$(nvim --version | head -n 1)
  echo "✅ Neovim is already installed: $NVIM_VERSION"
  exit 0
fi

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Darwin)
    echo "🍎 Detected macOS"
    if command -v brew &> /dev/null; then
      echo "📦 Installing Neovim via Homebrew..."
      brew install neovim
    else
      echo "❌ Homebrew not found. Please install Homebrew first:"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;
  Linux)
    echo "🐧 Detected Linux"
    if command -v brew &> /dev/null; then
      echo "📦 Installing Neovim via Homebrew..."
      brew install neovim
    elif command -v apt-get &> /dev/null; then
      echo "📦 Installing Neovim via apt..."
      sudo apt-get update
      sudo apt-get install -y neovim
    elif command -v dnf &> /dev/null; then
      echo "📦 Installing Neovim via dnf..."
      sudo dnf install -y neovim
    elif command -v pacman &> /dev/null; then
      echo "📦 Installing Neovim via pacman..."
      sudo pacman -S --noconfirm neovim
    elif command -v apk &> /dev/null; then
      echo "📦 Installing Neovim via apk..."
      sudo apk add neovim
    else
      echo "❌ No supported package manager found (brew, apt, dnf, pacman, apk)"
      echo "   Please install Neovim manually from: https://github.com/neovim/neovim/releases"
      exit 1
    fi
    ;;
  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install Neovim manually from: https://github.com/neovim/neovim/releases"
    exit 1
    ;;
esac

# Verify installation
if command -v nvim &> /dev/null; then
  NVIM_VERSION=$(nvim --version | head -n 1)
  echo "✅ Neovim successfully installed: $NVIM_VERSION"
else
  echo "❌ Neovim installation failed"
  exit 1
fi

# Setup Neovim configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/setup_nvim_config.sh"
