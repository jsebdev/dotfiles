#!/bin/bash

set -e

echo "🔧 Starting dotfiles installation..."

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y%m%d%H%M%S)"
SHELL_NAME="$(basename "$SHELL")"

# Detect active shell
echo "🐚 Detected shell: $SHELL_NAME"

# Files to link depending on shell
if [[ "$SHELL_NAME" == "zsh" ]]; then
  FILES_TO_LINK=(
    "zsh/.zshrc"
    "zsh/.zsh_aliases"
  )
elif [[ "$SHELL_NAME" == "bash" ]]; then
  FILES_TO_LINK=(
    "bash/.bashrc"
    "bash/.bash_aliases"
    "bash/.bash_profile"
  )
else
  echo "❌ Unsupported shell: $SHELL_NAME"
  exit 1
fi

# Always link .gitconfig (shared)
 FILES_TO_LINK+=(".gitconfig")
 FILES_TO_LINK+=(".tmux.conf")

# Backup and link
mkdir -p "$BACKUP_DIR"

for FILE in "${FILES_TO_LINK[@]}"; do
  BASENAME=$(basename "$FILE")
  TARGET="$HOME/$BASENAME"
  SOURCE="$DOTFILES_DIR/$FILE"

  echo "🔗 Processing $FILE"
  echo "📂 Target basename: $BASENAME"
  echo "📂 Target path: $TARGET"
  echo "📂 Source path: $SOURCE"

  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    echo "📦 Backing up $TARGET to $BACKUP_DIR"
    mv "$TARGET" "$BACKUP_DIR/"
  fi

  if [ -f "$SOURCE" ]; then
    echo "🔗 Linking $SOURCE → $TARGET"
    ln -s "$SOURCE" "$TARGET"
  else
    echo "⚠️ Skipping missing $SOURCE"
  fi
done

# Optional secrets
if [ "$SHELL_NAME" == "zsh" ] && [ ! -f "$HOME/.zsh_secrets" ]; then
  echo "🛡️ Creating blank .zsh_secrets"
  touch "$HOME/.zsh_secrets"
fi

echo "✅ Dotfiles setup complete!"

