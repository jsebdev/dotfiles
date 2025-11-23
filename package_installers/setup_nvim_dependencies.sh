#!/bin/bash

set -e

echo "🔧 Setting up Neovim dependencies..."

# Check if a C compiler is already available
if command -v cc &> /dev/null || \
   command -v gcc &> /dev/null || \
   command -v clang &> /dev/null || \
   command -v cl &> /dev/null || \
   command -v zig &> /dev/null; then
  echo "✅ C compiler already installed"
  exit 0
fi

echo "📦 Installing C compiler and build tools..."

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing build-essential on Linux..."
    sudo apt-get update
    sudo apt-get install -y build-essential
    echo "✅ build-essential installed successfully"
    ;;

  Darwin)
    echo "🍎 Installing Xcode Command Line Tools on macOS..."
    xcode-select --install
    echo "✅ Xcode Command Line Tools installed successfully"
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install a C compiler (gcc or clang) manually"
    exit 1
    ;;
esac

# Verify installation
if command -v gcc &> /dev/null; then
  GCC_VERSION=$(gcc --version | head -n 1)
  echo "✅ GCC installed: $GCC_VERSION"
else
  echo "❌ Failed to install C compiler"
  exit 1
fi
