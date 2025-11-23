#!/bin/bash

set -e

echo "📦 Installing Node.js via nvm..."

# Check if Node.js is already installed
if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  echo "✅ Node.js already installed: $NODE_VERSION"
  exit 0
fi

# Check if nvm is installed
if [ ! -d "$HOME/.nvm" ]; then
  echo "📥 Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
  echo "✅ nvm already installed"
fi

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install latest LTS version of Node.js
echo "📥 Installing Node.js LTS..."
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

# Verify installation
if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  NPM_VERSION=$(npm --version)
  echo "✅ Node.js installed: $NODE_VERSION"
  echo "✅ npm installed: $NPM_VERSION"
else
  echo "❌ Failed to install Node.js"
  exit 1
fi
