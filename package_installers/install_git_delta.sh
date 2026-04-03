#!/bin/bash

# git-delta: a syntax-highlighting pager for git diffs
# https://dandavison.github.io/delta/installation.html

set -e

echo "Installing git-delta..."

if command -v delta &> /dev/null; then
  DELTA_VERSION=$(delta --version | head -n 1)
  echo "git-delta already installed: $DELTA_VERSION"
  exit 0
fi

OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "Installing git-delta on Linux via apt-get..."
    sudo apt-get update
    sudo apt-get install -y git-delta
    ;;

  Darwin)
    echo "Installing git-delta on macOS via Homebrew..."

    if command -v brew &> /dev/null; then
      brew install git-delta
    else
      echo "Homebrew not found. Please install Homebrew first:"
      echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;

  *)
    echo "Unsupported OS: $OS"
    echo "Install git-delta manually: https://dandavison.github.io/delta/installation.html"
    exit 1
    ;;
esac

if command -v delta &> /dev/null; then
  DELTA_VERSION=$(delta --version | head -n 1)
  echo "git-delta installed successfully: $DELTA_VERSION"
else
  echo "Failed to install git-delta"
  exit 1
fi
