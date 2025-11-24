#!/bin/bash

set -e

echo "🔧 Starting dotfiles installation..."

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup/$(date +%Y-%m-%d_%H-%M-%S)"
SHELL_NAME="$(basename "$SHELL")"

# Detect active shell
echo "🐚 Detected shell: $SHELL_NAME"

# Files to link depending on shell
if [[ "$SHELL_NAME" == "zsh" ]]; then
  FILES_TO_LINK=(
    "zsh/.zshrc"
    "zsh/.zsh_aliases.sh"
    "zsh/.zsh_secrets.sh"
  )
elif [[ "$SHELL_NAME" == "bash" ]]; then
  FILES_TO_LINK=(
    "bash/.bashrc"
    "bash/.bash_aliases.sh"
    "bash/.bash_profile.sh"
  )
else
  echo "❌ Unsupported shell: $SHELL_NAME"
  exit 1
fi

# Always link .gitconfig (shared)
FILES_TO_LINK+=("shared/.dotfiles_utils.sh")
FILES_TO_LINK+=(".gitconfig")
FILES_TO_LINK+=(".tmux.conf")
FILES_TO_LINK+=("shared/.m8_aliases.sh")
FILES_TO_LINK+=("shared/.dotfiles_shared.sh")
FILES_TO_LINK+=("shared/.shared_aliases.sh")
FILES_TO_LINK+=("shared/.shared_functions.sh")

echo ""
echo "Files to link:"
for FILE in "${FILES_TO_LINK[@]}"; do
  echo " - $FILE"
done

# Backup and link

for FILE in "${FILES_TO_LINK[@]}"; do
  BASENAME=$(basename "$FILE")
  TARGET="$HOME/$BASENAME"
  SOURCE="$DOTFILES_DIR/$FILE"

  echo ""

  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" == "$SOURCE" ]; then
      echo "✅ $TARGET already correctly linked. Skipping backup."
      rm "$TARGET"
    else
      echo "📦 Backing up $TARGET to $BACKUP_DIR"
      mkdir -p "$BACKUP_DIR"
      mv "$TARGET" "$BACKUP_DIR/"
    fi
  fi

  if [ -f "$SOURCE" ]; then
    echo "🔗 Linking $SOURCE → $TARGET"
    ln -s "$SOURCE" "$TARGET"
  else
    echo "⚠️ Skipping missing $SOURCE"
  fi
done

echo ""
echo "📦 Installing packages..."
"$DOTFILES_DIR/package_installers/install_unzip.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_miniconda.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_aws_cli.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_aws_session_manager.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_fzf.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_ripgrep.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_pyenv.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_node.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/setup_nvim.sh"
echo ""
echo "-----"
echo ""
"$DOTFILES_DIR/package_installers/install_claude_code.sh"
echo ""
echo "-----"
echo ""

echo ""
echo "✅ Dotfiles setup complete!"

