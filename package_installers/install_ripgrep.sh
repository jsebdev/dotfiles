#!/bin/bash

# necessary for the telescope plugin in nvim

set -e

echo "🔍 Installing ripgrep..."

# Check if ripgrep is already installed
if command -v rg &> /dev/null; then
  RG_VERSION=$(rg --version | head -n 1)
  echo "✅ ripgrep already installed: $RG_VERSION"
  exit 0
fi

echo "📦 Installing ripgrep..."

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing ripgrep on Linux (using apt-get)..."
    sudo apt-get update
    sudo apt-get install -y ripgrep
    ;;

  Darwin)
    echo "🍎 Installing ripgrep on macOS..."

    if command -v brew &> /dev/null; then
      brew install ripgrep
    else
      echo "❌ Homebrew not found. Please install Homebrew first:"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install ripgrep manually: https://github.com/BurntSushi/ripgrep#installation"
    exit 1
    ;;
esac

# Verify installation
if command -v rg &> /dev/null; then
  RG_VERSION=$(rg --version | head -n 1)
  echo "✅ ripgrep installed successfully: $RG_VERSION"
else
  echo "❌ Failed to install ripgrep"
  exit 1
fi
