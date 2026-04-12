#!/bin/bash

set -e

echo "🐍 Installing uv..."

if command -v uv &> /dev/null; then
  UV_VERSION=$(uv --version)
  echo "✅ uv already installed: $UV_VERSION"
  exit 0
fi

echo "📦 Installing uv..."

OS="$(uname -s)"

case "$OS" in
  Linux|Darwin)
    curl -LsSf https://astral.sh/uv/install.sh | sh
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install uv manually: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
    ;;
esac

if command -v uv &> /dev/null; then
  UV_VERSION=$(uv --version)
  echo "✅ uv installed successfully: $UV_VERSION"
else
  echo "❌ Failed to install uv"
  exit 1
fi
