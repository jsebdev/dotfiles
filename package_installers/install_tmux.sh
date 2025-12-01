#!/bin/bash

set -e

echo "📦 Installing tmux..."

# Check if tmux is already installed
if command -v tmux &> /dev/null; then
  TMUX_VERSION=$(tmux -V)
  echo "✅ tmux already installed: $TMUX_VERSION"
  exit 0
fi

echo "📦 Installing tmux..."

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing tmux on Linux (using apt-get)..."
    sudo apt-get update
    sudo apt-get install -y tmux
    ;;

  Darwin)
    echo "🍎 Installing tmux on macOS..."
    if command -v brew &> /dev/null; then
      brew install tmux
    else
      echo "❌ Homebrew not found. Please install Homebrew first:"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install tmux manually"
    exit 1
    ;;
esac

# Verify installation
if command -v tmux &> /dev/null; then
  TMUX_VERSION=$(tmux -V)
  echo "✅ tmux installed successfully: $TMUX_VERSION"
else
  echo "❌ Failed to install tmux"
  exit 1
fi
