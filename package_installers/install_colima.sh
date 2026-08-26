#!/bin/bash

# colima: container runtimes on macOS with minimal setup
# https://github.com/abiosoft/colima

set -e

echo "Installing colima..."

OS="$(uname -s)"

case "$OS" in
  Darwin)
    if ! command -v brew &> /dev/null; then
      echo "Homebrew not found. Please install Homebrew first:"
      echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
      exit 1
    fi

    if command -v docker &> /dev/null; then
      echo "docker client already installed: $(docker --version)"
    else
      echo "Installing docker client on macOS via Homebrew..."
      brew install docker
    fi

    if command -v colima &> /dev/null; then
      echo "colima already installed: $(colima version | head -n 1)"
      exit 0
    fi

    echo "Installing colima on macOS via Homebrew..."
    brew install colima
    ;;

  Linux)
    echo "colima is not needed on Linux, docker runs natively. Skipping."
    exit 0
    ;;

  *)
    echo "Unsupported OS: $OS"
    echo "Install colima manually: https://github.com/abiosoft/colima#installation"
    exit 1
    ;;
esac

if command -v colima &> /dev/null; then
  echo "colima installed successfully: $(colima version | head -n 1)"
else
  echo "Failed to install colima"
  exit 1
fi
