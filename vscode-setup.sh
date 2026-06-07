#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  vscode-setup — VSCode + extensions + settings
#  ═══════════════════════════════════════════════════════════════════
#  Installs official VSCode, GitHub theme, Flutter, Remote
#  Development, ADB QR, Web Preview, and more.
#
#  USAGE:
#    bash vscode-setup.sh
#    bash vscode-setup.sh --help
#  ═══════════════════════════════════════════════════════════════════

set -euo pipefail

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

ok()   { echo "  ${GREEN}✓${RESET} $1"; }
warn() { echo "  ${YELLOW}→${RESET} $1"; }
fail() { echo "  ${RED}✗${RESET} $1"; }
info() { echo "  ${CYAN}i${RESET} $1"; }

setup_vscode() {
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  VSCode Setup                                       │"
  echo "  └─────────────────────────────────────────────────────┘"

  # ── 1. Install official VSCode ─────────────────────────────
  info "Installing official VSCode..."

  if command -v code &>/dev/null; then
    ok "VSCode already installed ($(code --version 2>/dev/null | head -1))"
  else
    if ! command -v yay &>/dev/null; then
      warn "yay not found. Installing yay first..."
      git clone https://aur.archlinux.org/yay.git /tmp/yay 2>/dev/null
      (cd /tmp/yay && makepkg -si --noconfirm) 2>/dev/null
      rm -rf /tmp/yay
    fi
    yay -S visual-studio-code-bin --noconfirm 2>&1 | tail -1
    if command -v code &>/dev/null; then
      ok "VSCode installed"
    else
      fail "VSCode installation failed"
      return 1
    fi
  fi

  # ── 2. Install extensions ──────────────────────────────────
  echo ""
  info "Installing extensions..."

  local extensions=(
    # GitHub theme
    "GitHub.github-vscode-theme"

    # Flutter / Dart
    "Dart-Code.flutter"
    "Dart-Code.dart-code"

    # Remote Development
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.vscode-remote-extensionpack"

    # ADB QR (Android Debug Bridge via QR)
    "vadimcn.vscode-adb"

    # Web Preview
    "ms-vscode.live-server"

    # Problems copy
    "arturodent.problems-copy"
  )

  local installed=0 failed=0
  for ext in "${extensions[@]}"; do
    if code --install-extension "$ext" --force &>/dev/null; then
      installed=$((installed + 1))
    else
      failed=$((failed + 1))
      warn "Failed to install: $ext"
    fi
  done
  ok "$installed extensions installed"
  [ "$failed" -gt 0 ] && warn "$failed extensions failed (may need manual install)"

  # ── 3. Fira Code font ──────────────────────────────────────
  if ! pacman -Q ttf-fira-code &>/dev/null 2>&1; then
    sudo pacman -Syy --noconfirm
    sudo pacman -S --noconfirm ttf-fira-code 2>&1 | tail -1
    ok "Fira Code font installed"
  else
    info "Fira Code font already installed"
  fi

  # ── 4. Configure settings ──────────────────────────────────
  echo ""
  info "Configuring VSCode settings..."

  local config_dir="$HOME/.config/Code/User"
  mkdir -p "$config_dir"

  cat > "$config_dir/settings.json" <<'JSON'
{
    "editor.fontFamily": "Jetbrains Mono",
    "editor.fontSize": 17,
    "editor.fontLigatures": true,
    "workbench.colorTheme": "GitHub Dark Default",
    "workbench.iconTheme": "vs-minimal",
    "files.autoSave": "onFocusChange",
    "dart.flutterSdkPath": "~/flutter",
    "dart.sdkPath": "~/flutter/bin/cache/dart-sdk",
    "terminal.integrated.fontFamily": "Jetbrains Mono",
    "editor.minimap.enabled": false,
    "workbench.startupEditor": "none",
    "extensions.autoUpdate": true,
    "remote.SSH.connectTimeout": 30,
    "remote.SSH.showLoginTerminal": true,
    "liveServer.settings.donotShowInfoMsg": true
}
JSON
  ok "VSCode settings configured"

  # ── 5. Done ────────────────────────────────────────────────
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  VSCode Setup Complete                              │"
  echo "  ├─────────────────────────────────────────────────────┤"
  echo "  │  Run: code                                          │"
  echo "  │                                                     │"
  echo "  │  Extensions installed:                              │"
  echo "  │    • GitHub Theme                                   │"
  echo "  │    • Flutter + Dart                                 │"
  echo "  │    • Remote Development (SSH + Containers)          │"
  echo "  │    • ADB QR (Android wireless debug)                │"
  echo "  │    • MS Web Preview                                 │"
  echo "  │    • Problems Copy                                  │"
  echo "  └─────────────────────────────────────────────────────┘"
}

case "${1:-}" in
  --help|-h)
    echo "Usage: bash vscode-setup.sh"
    exit 0
    ;;
  *)
    setup_vscode
    ;;
esac
