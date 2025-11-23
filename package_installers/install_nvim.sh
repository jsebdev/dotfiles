#!/bin/bash

set -e

echo "🚀 Installing Neovim..."

# Minimum required version
MIN_VERSION="0.11.0"

# Check if nvim is already installed and meets minimum version
if command -v nvim &> /dev/null; then
  NVIM_VERSION=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || echo "0.0.0")
  echo "✅ Neovim is already installed: v$NVIM_VERSION"

  # Compare versions (simple numeric comparison for major.minor)
  CURRENT_MAJOR=$(echo "$NVIM_VERSION" | cut -d. -f1)
  CURRENT_MINOR=$(echo "$NVIM_VERSION" | cut -d. -f2)
  MIN_MAJOR=$(echo "$MIN_VERSION" | cut -d. -f1)
  MIN_MINOR=$(echo "$MIN_VERSION" | cut -d. -f2)

  if [ "$CURRENT_MAJOR" -gt "$MIN_MAJOR" ] || \
     ([ "$CURRENT_MAJOR" -eq "$MIN_MAJOR" ] && [ "$CURRENT_MINOR" -ge "$MIN_MINOR" ]); then
    echo "✅ Version meets minimum requirement ($MIN_VERSION)"
    exit 0
  else
    echo "⚠️  Version v$NVIM_VERSION is below minimum requirement ($MIN_VERSION). Upgrading..."
  fi
fi

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

# Neovim version to install
NVIM_VERSION="v0.11.5"
INSTALL_DIR="$HOME/.local"

case "$OS" in
  Darwin)
    echo "🍎 Detected macOS ($ARCH)"
    echo "📦 Installing Neovim ${NVIM_VERSION} from official releases..."

    DOWNLOAD_DIR="/tmp/nvim-install"
    mkdir -p "$DOWNLOAD_DIR"
    mkdir -p "$INSTALL_DIR/bin"

    cd "$DOWNLOAD_DIR"

    if [ "$ARCH" = "arm64" ]; then
      TARBALL="nvim-macos-arm64.tar.gz"
      DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${TARBALL}"
      EXTRACTED_DIR="nvim-macos-arm64"
    else
      TARBALL="nvim-macos-x86_64.tar.gz"
      DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${TARBALL}"
      EXTRACTED_DIR="nvim-macos-x86_64"
    fi

    echo "📥 Downloading ${TARBALL}..."
    curl -L "$DOWNLOAD_URL" -o "$TARBALL"

    echo "🔓 Removing quarantine attribute..."
    xattr -c "./${TARBALL}"

    echo "📦 Extracting..."
    tar xzvf "$TARBALL"

    echo "📂 Installing to $INSTALL_DIR..."
    rm -rf "$INSTALL_DIR/$EXTRACTED_DIR"
    mv "$EXTRACTED_DIR" "$INSTALL_DIR/"

    # Create symlink
    ln -sf "$INSTALL_DIR/$EXTRACTED_DIR/bin/nvim" "$INSTALL_DIR/bin/nvim"

    cd - > /dev/null
    rm -rf "$DOWNLOAD_DIR"

    echo "🔗 Symlink created: $INSTALL_DIR/bin/nvim"
    echo "⚠️  Make sure $INSTALL_DIR/bin is in your PATH"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$INSTALL_DIR/bin:"* ]]; then
      echo ""
      echo "Add this to your shell configuration:"
      echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    ;;

  Linux)
    echo "🐧 Detected Linux ($ARCH)"

    if [ "$ARCH" = "x86_64" ]; then
      echo "📦 Installing Neovim ${NVIM_VERSION} AppImage..."

      DOWNLOAD_DIR="/tmp/nvim-install"
      mkdir -p "$DOWNLOAD_DIR"
      mkdir -p "$INSTALL_DIR/bin"

      cd "$DOWNLOAD_DIR"

      APPIMAGE="nvim.appimage"
      DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"

      echo "📥 Downloading ${APPIMAGE}..."
      curl -L "$DOWNLOAD_URL" -o "$APPIMAGE"

      echo "🔑 Making executable..."
      chmod u+x "$APPIMAGE"

      # Check if FUSE is available by trying to run the AppImage
      if ./"$APPIMAGE" --version &> /dev/null; then
        echo "✅ FUSE is available, AppImage can run directly"
        mv "$APPIMAGE" "$INSTALL_DIR/bin/nvim"
      else
        echo "⚠️  FUSE not available, extracting AppImage..."
        ./"$APPIMAGE" --appimage-extract

        rm -rf "$INSTALL_DIR/nvim-squashfs-root"
        mv squashfs-root "$INSTALL_DIR/nvim-squashfs-root"

        # Create a wrapper script
        cat > "$INSTALL_DIR/bin/nvim" << 'EOF'
#!/bin/bash
exec "$HOME/.local/nvim-squashfs-root/usr/bin/nvim" "$@"
EOF
        chmod +x "$INSTALL_DIR/bin/nvim"
      fi

      cd - > /dev/null
      rm -rf "$DOWNLOAD_DIR"

      echo "✅ Neovim installed to $INSTALL_DIR/bin/nvim"
      echo "⚠️  Make sure $INSTALL_DIR/bin is in your PATH"

      # Add to PATH if not already there
      if [[ ":$PATH:" != *":$INSTALL_DIR/bin:"* ]]; then
        echo ""
        echo "Add this to your shell configuration:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
      fi
    else
      echo "❌ Unsupported architecture: $ARCH"
      echo "   Official Neovim releases only support x86_64 for Linux"
      echo "   Please install manually from: https://github.com/neovim/neovim/releases"
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $OS"
    echo "   Please install Neovim manually from: https://github.com/neovim/neovim/releases"
    exit 1
    ;;
esac

# Verify installation
if command -v nvim &> /dev/null; then
  NVIM_VERSION=$(nvim --version | head -n 1)
  echo "✅ Neovim successfully installed: $NVIM_VERSION"
else
  echo "❌ Neovim installation failed"
  exit 1
fi

# Setup Neovim dependencies (C compiler for Treesitter)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/setup_nvim_dependencies.sh"

# Setup Neovim configuration
"$SCRIPT_DIR/setup_nvim_config.sh"
