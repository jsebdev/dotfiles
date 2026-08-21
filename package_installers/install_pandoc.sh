#!/bin/bash

# required by dotfiles_scripts/md2pdf to convert markdown to HTML

set -e

echo "🔍 Installing pandoc..."

if command -v pandoc &> /dev/null; then
  PANDOC_VERSION=$(pandoc --version | head -n 1)
  echo "✅ pandoc already installed: $PANDOC_VERSION"
  exit 0
fi

echo "📦 Installing pandoc..."

OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing pandoc on Linux (using apt-get)..."
    sudo apt-get update
    sudo apt-get install -y pandoc
    ;;

  Darwin)
    echo "🍎 Installing pandoc on macOS..."

    if command -v brew &> /dev/null; then
      brew install pandoc
    else
      echo "❌ Homebrew not found. Please install Homebrew first:"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install pandoc manually: https://pandoc.org/installing.html"
    exit 1
    ;;
esac

if command -v pandoc &> /dev/null; then
  PANDOC_VERSION=$(pandoc --version | head -n 1)
  echo "✅ pandoc installed successfully: $PANDOC_VERSION"
else
  echo "❌ Failed to install pandoc"
  exit 1
fi
