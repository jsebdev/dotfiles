#!/bin/bash

# Only relevant for zsh (macOS), where BSD grep lacks full color support
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
  echo "⏭️  Skipping GNU grep (not a zsh shell)"
  exit 0
fi

set -e

echo "🔍 Installing GNU grep..."

if command -v ggrep &> /dev/null; then
  echo "✅ GNU grep already installed: $(ggrep --version | head -n 1)"
  exit 0
fi

OS="$(uname -s)"

case "$OS" in
  Darwin)
    if command -v brew &> /dev/null; then
      brew install grep
    else
      echo "❌ Homebrew not found. Please install Homebrew first."
      exit 1
    fi
    ;;
  *)
    echo "⏭️  Skipping GNU grep (only needed on macOS, Linux grep already supports full color)"
    exit 0
    ;;
esac

if command -v ggrep &> /dev/null; then
  echo "✅ GNU grep installed successfully: $(ggrep --version | head -n 1)"
else
  echo "❌ Failed to install GNU grep"
  exit 1
fi
