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
