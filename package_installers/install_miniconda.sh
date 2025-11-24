#!/bin/bash

set -e

echo "🐍 Checking miniconda installation..."

# Check if conda is already installed
if command -v conda &> /dev/null; then
    echo "✅ miniconda is already installed"
    conda --version
    exit 0
fi

echo "📦 Installing miniconda..."

# Create miniconda directory
mkdir -p ~/miniconda3

# Detect OS and download appropriate installer
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detected Linux, downloading Linux installer..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Detected macOS, downloading macOS installer..."
    curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

# Run the installer
echo "🔧 Running miniconda installer..."
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3

# Clean up installer
echo "🧹 Cleaning up installer..."
rm ~/miniconda3/miniconda.sh

# Initialize conda for bash and zsh only (the shells managed by this dotfiles repo)
echo "🔧 Initializing conda for bash and zsh..."
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

echo "✅ miniconda installation complete!"
echo "⚠️  Please restart your shell or run 'source ~/.$(basename "$SHELL")rc' to use conda"
echo "📝 Note: conda init has modified your shell configuration files (.bashrc, .zshrc)"
echo "   Review and commit these changes to your dotfiles repository"
