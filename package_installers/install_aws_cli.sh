#!/bin/bash

set -e

echo "☁️  Installing AWS CLI..."

# Check if AWS CLI is already installed
if command -v aws &> /dev/null; then
  AWS_VERSION=$(aws --version 2>&1 | head -n 1)
  echo "✅ AWS CLI already installed: $AWS_VERSION"
  exit 0
fi

echo "📦 Installing AWS CLI..."

# Detect OS
OS="$(uname -s)"

case "$OS" in
  Linux)
    echo "🐧 Installing AWS CLI on Linux..."

    # Download AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"

    # Unzip (requires unzip to be installed)
    unzip -q /tmp/awscliv2.zip -d /tmp

    # Install
    sudo /tmp/aws/install

    # Cleanup
    rm -rf /tmp/awscliv2.zip /tmp/aws
    ;;

  Darwin)
    echo "🍎 Installing AWS CLI on macOS..."

    # Download AWS CLI
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"

    # Install
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /

    # Cleanup
    rm /tmp/AWSCLIV2.pkg
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install AWS CLI manually: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
    ;;
esac

# Verify installation
if command -v aws &> /dev/null; then
  AWS_VERSION=$(aws --version 2>&1 | head -n 1)
  echo "✅ AWS CLI installed successfully: $AWS_VERSION"
else
  echo "❌ Failed to install AWS CLI"
  exit 1
fi
