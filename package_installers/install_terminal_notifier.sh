#!/bin/bash

set -e

echo "🔔 Installing terminal-notifier..."

if command -v terminal-notifier &> /dev/null; then
  echo "✅ terminal-notifier already installed: $(terminal-notifier -help 2>&1 | head -n 1)"
  exit 0
fi

OS="$(uname -s)"

case "$OS" in
  Darwin)
    echo "🍎 Installing terminal-notifier on macOS..."
    if command -v brew &> /dev/null; then
      brew install terminal-notifier
    else
      echo "❌ Homebrew not found. Please install Homebrew first:"
      echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi
    ;;

  Linux)
    echo "⏭️  terminal-notifier is macOS-only. Skipping on Linux."
    exit 0
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

if command -v terminal-notifier &> /dev/null; then
  echo "✅ terminal-notifier installed successfully"
else
  echo "❌ Failed to install terminal-notifier"
  exit 1
fi
