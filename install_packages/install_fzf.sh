#!/bin/bash

set -e

echo "🔍 Checking fzf installation..."

# Check if fzf is already installed
if command -v fzf &> /dev/null; then
    echo "✅ fzf is already installed"
    fzf --version
    exit 0
fi

echo "📦 Installing fzf using git method..."

# Clone fzf repository if it doesn't exist
if [ -d "$HOME/.fzf" ]; then
    echo "⚠️  fzf directory already exists at ~/.fzf"
    echo "   Updating existing installation..."
    cd "$HOME/.fzf"
    git pull
else
    echo "📥 Cloning fzf repository..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi

# Run the fzf install script
echo "🔧 Running fzf install script..."
"$HOME/.fzf/install" --all

echo "✅ fzf installation complete!"
