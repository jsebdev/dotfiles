#!/bin/bash

# necessary for mason to extract downloaded packages in nvim
# like stylua and clangd

set -e

echo "📦 Installing unzip..."

# Check if unzip is already installed
if command -v unzip &> /dev/null; then
  UNZIP_VERSION=$(unzip -v | head -n 1)
  echo "✅ unzip already installed: $UNZIP_VERSION"
  exit 0
fi

echo "📦 Installing unzip..."

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing unzip on Linux (using apt-get)..."
    sudo apt-get update
    sudo apt-get install -y unzip
    ;;

  Darwin)
    echo "🍎 Installing unzip on macOS..."
    if command -v brew &> /dev/null; then
      brew install unzip
    else
      echo "❌ Homebrew not found. Please install Homebrew first:"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install unzip manually"
    exit 1
    ;;
esac

# Verify installation
if command -v unzip &> /dev/null; then
  UNZIP_VERSION=$(unzip -v | head -n 1)
  echo "✅ unzip installed successfully: $UNZIP_VERSION"
else
  echo "❌ Failed to install unzip"
  exit 1
fi
