#!/bin/bash
# smartDots Cross-Platform Installer
# Detects OS and runs the appropriate setup
# Usage: bash install.sh

set -euo pipefail

REPO_URL="https://github.com/AmarjithTK/smartDots.git"
BRANCH="main3"
DEST_DIR="$HOME/smartDots"

echo "=== smartDots Cross-Platform Installer ==="

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Linux)
    echo "Detected: Linux"
    if [[ ! -d "$DEST_DIR" ]]; then
      git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_URL" "$DEST_DIR"
    else
      echo "Directory $DEST_DIR already exists. Pulling updates..."
      cd "$DEST_DIR" && git pull origin "$BRANCH"
    fi

    echo ""
    echo "Running bootstrap..."
    cd "$DEST_DIR"
    bash linux/setup/bootstrap.sh
    ;;
  *)
    echo "Detected: $OS"
    echo "Windows users: checkout the 'windows' branch or run:"
    echo "  powershell -ExecutionPolicy Bypass -File windows/install.ps1"
    echo ""
    echo "Or clone and copy files manually:"
    echo "  git clone -b $BRANCH $REPO_URL %USERPROFILE%\\smartDots"
    echo "  cd windows"
    echo "  powershell -ExecutionPolicy Bypass -File install.ps1"
    exit 0
    ;;
esac

echo ""
echo "=== smartDots setup complete! ==="
