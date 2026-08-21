#!/bin/bash

# links dotfiles_scripts/md2pdf onto PATH via ~/.local/bin

set -e

echo "🔗 Setting up md2pdf..."

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$DOTFILES_DIR/dotfiles_scripts/md2pdf"
BIN_DIR="$HOME/.local/bin"
TARGET="$BIN_DIR/md2pdf"

if [ ! -f "$SOURCE" ]; then
  echo "❌ Missing $SOURCE"
  exit 1
fi

chmod +x "$SOURCE"
mkdir -p "$BIN_DIR"

if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" == "$SOURCE" ]; then
  echo "✅ $TARGET already correctly linked."
else
  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    echo "🗑️  Replacing existing $TARGET"
    rm "$TARGET"
  fi
  echo "🔗 Linking $SOURCE → $TARGET"
  ln -s "$SOURCE" "$TARGET"
fi

case ":$PATH:" in
  *":$BIN_DIR:"*)
    echo "✅ md2pdf is on PATH"
    ;;
  *)
    echo "⚠️  $BIN_DIR is not on PATH. Add it in your shell config:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac
