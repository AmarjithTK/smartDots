#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  vscode-setup — VSCodium + extensions + settings
#  ═══════════════════════════════════════════════════════════════════
#  Derived from main2 branch: vscode.setup
#
#  Installs VSCodium (AUR), Material Theme + icons, vim bindings,
#  Flutter/Dart support, and sane editor defaults.
#
#  USAGE:
#    bash vscode-setup.sh
#    bash vscode-setup.sh --help
#  ═══════════════════════════════════════════════════════════════════

set -euo pipefail

WHITE='\033[1;37m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
warn() { echo -e "  ${YELLOW}→${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; }
info() { echo -e "  ${CYAN}i${RESET} $1"; }

setup_vscode() {
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  VSCodium Setup                                     │"
  echo "  └─────────────────────────────────────────────────────┘"

  # ── 1. Install VSCodium ───────────────────────────────────
  info "Installing VSCodium..."

  if command -v codium &>/dev/null; then
    ok "VSCodium already installed"
  else
    if ! command -v yay &>/dev/null; then
      warn "yay not found. Installing yay first..."
      git clone https://aur.archlinux.org/yay.git /tmp/yay 2>/dev/null
      (cd /tmp/yay && makepkg -si --noconfirm) 2>/dev/null
      rm -rf /tmp/yay
    fi
    yay -S vscodium-bin --noconfirm 2>&1 | tail -1
    if command -v codium &>/dev/null; then
      ok "VSCodium installed"
    else
      fail "VSCodium installation failed"
      return 1
    fi
  fi

  # ── 2. Install extensions ─────────────────────────────────
  echo ""
  info "Installing extensions..."

  local extensions=(
    "Equinusocio.vsc-material-theme"
    "PKief.material-icon-theme"
    "Dart-Code.flutter"
    "Dart-Code.dart-code"
    "vscodevim.vim"
  )

  local installed=0
  for ext in "${extensions[@]}"; do
    if codium --install-extension "$ext" --force &>/dev/null; then
      ((installed++))
    fi
  done
  ok "$installed extensions installed"

  # ── 3. Fira Code font ─────────────────────────────────────
  if ! pacman -Q ttf-fira-code &>/dev/null 2>&1; then
    sudo pacman -S ttf-fira-code --noconfirm 2>&1 | tail -1
    ok "Fira Code font installed"
  else
    info "Fira Code font already installed"
  fi

  # ── 4. Configure settings ─────────────────────────────────
  echo ""
  info "Configuring VSCodium settings..."

  local config_dir="$HOME/.config/VSCodium/User"
  mkdir -p "$config_dir"

  cat > "$config_dir/settings.json" <<'JSON'
{
    "editor.fontFamily": "Jetbrains Mono",
    "editor.fontSize": 17,
    "editor.fontLigatures": true,
    "workbench.colorTheme": "Material Theme Ocean High Contrast",
    "workbench.iconTheme": "material-icon-theme",
    "files.autoSave": "onFocusChange",
    "dart.flutterSdkPath": "~/flutter",
    "dart.sdkPath": "~/flutter/bin/cache/dart-sdk",
    "terminal.integrated.fontFamily": "Jetbrains Mono",
    "editor.minimap.enabled": false,
    "workbench.startupEditor": "none",
    "extensions.autoUpdate": true
}
JSON
  ok "VSCodium settings configured"

  # ── 5. Done ───────────────────────────────────────────────
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  VSCodium Setup Complete                            │"
  echo "  ├─────────────────────────────────────────────────────┤"
  echo "  │  Run: codium                                        │"
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
