#!/bin/bash

set -e

echo "📦 Installing pyenv..."

# Check if pyenv is already installed
if [ -d "$HOME/.pyenv" ]; then
  echo "✅ pyenv already installed"

  # Load pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  PYENV_VERSION=$(pyenv --version)
  echo "   Version: $PYENV_VERSION"
else
  echo "📥 Installing pyenv via automatic installer..."

  # Detect OS for dependencies
  OS="$(uname -s)"

  case "$OS" in
    Linux)
      echo "🐧 Installing build dependencies on Linux (using apt-get)..."
      sudo apt-get update
      sudo apt-get install -y \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev
      ;;

    Darwin)
      echo "🍎 On macOS, using Homebrew method..."
      if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew not found. Please install Homebrew first."
        exit 1
      fi
      brew update
      brew install pyenv
      ;;

    *)
      echo "⚠️  Unknown OS: $OS. Attempting automatic installer..."
      ;;
  esac

  # For Linux or if Homebrew install didn't happen, use automatic installer
  if [ ! -d "$HOME/.pyenv" ]; then
    curl -fsSL https://pyenv.run | bash
  fi

  # Load pyenv
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"

  PYENV_VERSION=$(pyenv --version)
  echo "✅ pyenv installed: $PYENV_VERSION"
fi

# Check if a Python version is already installed
INSTALLED_VERSIONS=$(pyenv versions --bare)

if [ -z "$INSTALLED_VERSIONS" ]; then
  echo "📥 Installing Python 3.12 (recommended stable version)..."
  pyenv install 3.12
  pyenv global 3.12

  PYTHON_VERSION=$(pyenv version)
  echo "✅ Python installed: $PYTHON_VERSION"
else
  echo "✅ Python versions already installed:"
  pyenv versions

  # Set global version if not set
  if ! pyenv global &> /dev/null; then
    FIRST_VERSION=$(echo "$INSTALLED_VERSIONS" | head -n 1)
    echo "📌 Setting global Python version to: $FIRST_VERSION"
    pyenv global "$FIRST_VERSION"
  fi
fi

# Upgrade pip for the current Python version
echo "📦 Upgrading pip..."
pip install --upgrade pip

echo "✅ pyenv setup complete"
