#!/bin/bash

set -e

echo "🔌 Installing AWS Session Manager Plugin..."

# Check if Session Manager Plugin is already installed
if command -v session-manager-plugin &> /dev/null; then
  echo "✅ AWS Session Manager Plugin already installed"
  session-manager-plugin --version 2>&1 || echo "(version check not available)"
  exit 0
fi

echo "📦 Installing AWS Session Manager Plugin..."

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing Session Manager Plugin on Linux..."

    # Download the deb package
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "/tmp/session-manager-plugin.deb"

    # Install
    sudo dpkg -i /tmp/session-manager-plugin.deb

    # Cleanup
    rm /tmp/session-manager-plugin.deb
    ;;

  Darwin)
    echo "🍎 Installing Session Manager Plugin on macOS..."

    # Detect architecture
    ARCH="$(uname -m)"

    if [ "$ARCH" = "arm64" ]; then
      echo "📱 Detected Apple Silicon (ARM64)"
      curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/session-manager-plugin.pkg" -o "/tmp/session-manager-plugin.pkg"
    else
      echo "💻 Detected Intel (x86_64)"
      curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/session-manager-plugin.pkg" -o "/tmp/session-manager-plugin.pkg"
    fi

    # Ensure /usr/local/bin exists
    sudo mkdir -p /usr/local/bin

    # Install
    sudo installer -pkg /tmp/session-manager-plugin.pkg -target /

    # Create symlink
    sudo ln -sf /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin

    # Cleanup
    rm /tmp/session-manager-plugin.pkg
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install Session Manager Plugin manually: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html"
    exit 1
    ;;
esac

# Verify installation
if command -v session-manager-plugin &> /dev/null; then
  echo "✅ AWS Session Manager Plugin installed successfully"
  session-manager-plugin --version 2>&1 || echo "(version check not available)"
else
  echo "❌ Failed to install AWS Session Manager Plugin"
  exit 1
fi
