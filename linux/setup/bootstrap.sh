#!/bin/bash
# smartDots Linux Bootstrap
# Orchestrates: stow symlinks → interactive setup scripts
# Usage: bash bootstrap.sh [--non-interactive]
#        bash bootstrap.sh packages|devtools|firefox

set -euo pipefail

SMARTDOTS_DIR="${SMARTDOTS_DIR:-$HOME/smartDots}"
SETUP_DIR="$SMARTDOTS_DIR/linux/setup"
STOW_DIR="$SMARTDOTS_DIR/linux/stow"
ARCHIVE_DIR="$SMARTDOTS_DIR/archive/stow"

# ─── Stow active dotfiles ─────────────────────────────────────
stow_active() {
  echo "=== Symlinking active dotfiles ==="
  cd "$SMARTDOTS_DIR"

  # Active (KDE-compatible) stow packages
  for pkg in shell kitty rofi dunst firefox plasma-autostart; do
    if [[ -d "$STOW_DIR/$pkg" ]]; then
      stow -d "$STOW_DIR" -t "$HOME" "$pkg" 2>/dev/null || \
        stow -d "$STOW_DIR" -t "$HOME" "$pkg" --adopt
      echo "  - stow: $pkg"
    fi
  done

  # Shared git config
  mkdir -p "$HOME/.config/git"
  cp -n "$SMARTDOTS_DIR/shared/git/.gitconfig" "$HOME/" 2>/dev/null || true
  cp -n "$SMARTDOTS_DIR/shared/git/.gitignore_global" "$HOME/" 2>/dev/null || true

  echo "=== Dotfiles symlinked ==="
}

# ─── Interactive menu ─────────────────────────────────────────
interactive_menu() {
  while true; do
    echo ""
    echo "=== smartDots Setup Menu ==="
    echo "1) Install base packages"
    echo "2) Install dev tools (ZSH, NVIM, VSCodium)"
    echo "3) Setup Firefox theme"
    echo "4) Brillo: KDE brightness widget + DDC/CI (desktops)"
    echo "5) Archive: stow BSPWM/Polybar/Picom configs"
    echo "q) Quit"
    echo ""
    read -p "Select (space-separated): " -a choices

    for c in "${choices[@]}"; do
      case "$c" in
        1) bash "$SETUP_DIR/packages.sh" ;;
        2) bash "$SETUP_DIR/devtools.sh" ;;
        3) bash "$SETUP_DIR/firefox.sh" ;;
        4) bash "$SETUP_DIR/plasmoid-brillo.sh" ;;
        5) stow_archive ;;
        q|Q) exit 0 ;;
        *) echo "Invalid: $c" ;;
      esac
    done
  done
}

# ─── Archive stow (optional, for BSPWM users) ────────────────
stow_archive() {
  echo "=== Archiving BSPWM/Polybar/Picom configs ==="
  cd "$SMARTDOTS_DIR"
  for pkg in bspwm sxhkd polybar picom; do
    if [[ -d "$ARCHIVE_DIR/$pkg" ]]; then
      stow -d "$ARCHIVE_DIR" -t "$HOME" "$pkg" 2>/dev/null || true
      echo "  - stow (archive): $pkg"
    fi
  done
}

# ─── Copy bin scripts to ~/.local/bin ─────────────────────────
install_bins() {
  echo "=== Installing scripts to ~/.local/bin ==="
  mkdir -p "$HOME/.local/bin"
  for script in "$SMARTDOTS_DIR/linux/bin/"*; do
    if [[ -f "$script" ]]; then
      cp "$script" "$HOME/.local/bin/"
      chmod +x "$HOME/.local/bin/$(basename "$script")"
    fi
  done
  echo "=== Scripts installed ==="
}

# ─── Main ─────────────────────────────────────────────────────
main() {
  stow_active
  install_bins

  if [[ "$1" == "--non-interactive" ]]; then
    echo "Non-interactive mode: skipping setup menu."
    echo "Run individual: bash $SETUP_DIR/packages.sh (etc.)"
    exit 0
  fi

  interactive_menu
}

main "${1:-}"
