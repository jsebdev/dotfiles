#!/bin/bash

set -e

echo "🐙 Installing GitHub CLI (gh)..."

if command -v gh &> /dev/null; then
  GH_VERSION=$(gh --version | head -n 1)
  echo "✅ GitHub CLI already installed: $GH_VERSION"
  exit 0
fi

OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing GitHub CLI on Linux (using apt-get)..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
    ;;

  Darwin)
    echo "🍎 Installing GitHub CLI on macOS..."
    if command -v brew &> /dev/null; then
      brew install gh
    else
      echo "❌ Homebrew not found. Please install Homebrew first:"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install GitHub CLI manually: https://github.com/cli/cli#installation"
    exit 1
    ;;
esac

if command -v gh &> /dev/null; then
  GH_VERSION=$(gh --version | head -n 1)
  echo "✅ GitHub CLI installed successfully: $GH_VERSION"
else
  echo "❌ Failed to install GitHub CLI"
  exit 1
fi
