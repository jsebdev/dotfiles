#!/bin/bash

set -e

echo "🤖 Checking Claude Code installation..."

# Check if Claude Code is already installed
if command -v claude &> /dev/null; then
    echo "✅ Claude Code is already installed"
    claude --version
else
    echo "📦 Installing Claude Code CLI..."

    # Install Claude Code using the official installation script
    curl -fsSL https://claude.ai/install.sh | bash

    # Verify installation
    if command -v claude &> /dev/null; then
        echo "✅ Claude Code installation complete!"
        claude --version
    else
        echo "✅ Claude Code installed! Please restart your shell to use the 'claude' command."
    fi
fi

# Setup Claude Code configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/setup_claude_config.sh"
