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

# ─── Ensure .zshrc sources .zshconfig (merge, not replace) ──
ensure_zshrc_sources_zshconfig() {
  local zshrc="$HOME/.zshrc"
  local zshconfig_source='[ -f "$HOME/.zshconfig" ] && . "$HOME/.zshconfig"'

  if [[ ! -f "$zshrc" ]]; then
    # No .zshrc exists — create one that sources .zshconfig
    cat > "$zshrc" <<'ZSHEOF'
# Default .zshrc — loads smartDots config
POWERLEVEL10K_DISABLE_CONFIGURATION_WIZARD=true
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
[ -f "$HOME/.zshconfig" ] && . "$HOME/.zshconfig"
ZSHEOF
    echo "  📝 created: ~/.zshrc (sources .zshconfig)"
  elif ! grep -q "zshconfig" "$zshrc" 2>/dev/null; then
    # .zshrc exists but doesn't source .zshconfig — append ONE line
    {
      echo ""
      echo "# smartDots: load custom config"
      echo '[ -f "$HOME/.zshconfig" ] && . "$HOME/.zshconfig"'
    } >> "$zshrc"
    echo "  📝 appended: ~/.zshrc now sources .zshconfig (existing config preserved)"
  else
    echo "  ℹ️  ~/.zshrc already sources .zshconfig — no change"
  fi
}

# ─── Stow active dotfiles (safe: backups existing files) ─────
stow_active() {
  echo "=== Symlinking active dotfiles ==="
  cd "$SMARTDOTS_DIR"

  local ts
  ts=$(date +%Y%m%d-%H%M%S)

  # Active (KDE-compatible) stow packages
  for pkg in kitty rofi dunst firefox plasma-autostart; do
    if [[ ! -d "$STOW_DIR/$pkg" ]]; then
      continue
    fi

    # Backup existing files that would be overwritten
    while IFS= read -r -d '' relpath; do
      local target="$HOME/$relpath"
      if [[ -f "$target" && ! -L "$target" ]]; then
        local bak="$target.bak.$ts"
        mv "$target" "$bak"
        echo "  📦 backed up: ~/$relpath → ~/$relpath.bak.$ts"
      fi
    done < <(cd "$STOW_DIR/$pkg" && find . -type f -print0)

    stow -d "$STOW_DIR" -t "$HOME" "$pkg" 2>/dev/null
    echo "  - stow: $pkg"
  done

  # Shell package: stow only .zshconfig (never replace .zshrc)
  if [[ -d "$STOW_DIR/shell" ]]; then
    # Stow only .zshconfig from the shell package
    while IFS= read -r -d '' relpath; do
      local target="$HOME/$relpath"
      # Only handle .zshconfig, skip .zshrc
      [[ "$relpath" == ".zshrc" ]] && continue
      if [[ -f "$target" && ! -L "$target" ]]; then
        local bak="$target.bak.$ts"
        mv "$target" "$bak"
        echo "  📦 backed up: ~/$relpath"
      fi
    done < <(cd "$STOW_DIR/shell" && find . -type f -print0)

    stow -d "$STOW_DIR" -t "$HOME" "shell" 2>/dev/null
    echo "  - stow: shell/.zshconfig"
  fi

  # Ensure .zshrc sources .zshconfig (merge, never replace)
  ensure_zshrc_sources_zshconfig

  # Shared git config (no-clobber: user's existing config is kept)
  mkdir -p "$HOME/.config/git"
  cp -n "$SMARTDOTS_DIR/shared/git/.gitconfig" "$HOME/" 2>/dev/null || true
  cp -n "$SMARTDOTS_DIR/shared/git/.gitignore_global" "$HOME/" 2>/dev/null || true

  echo "=== Dotfiles symlinked ==="
  echo "📦 Backups created with .bak.$ts suffix"
}

# ─── CLI Toolkit install ──────────────────────────────────────
install_cli_toolkit() {
  echo ""
  echo "=== Installing CLI Toolkit (aliases + helper) ==="
  bash "$SMARTDOTS_DIR/cli-toolkit/install.sh"
}

# ─── Interactive menu ─────────────────────────────────────────
interactive_menu() {
  while true; do
    echo ""
    echo "=== smartDots Setup Menu ==="
    echo "1) Install base packages"
    echo "2) Install dev tools (ZSH, NVIM, VSCodium)"
    echo "3) Setup Firefox theme"
    echo "4) CLI Toolkit: 60 aliases + helper command"
    echo "5) Brillo: KDE brightness widget + DDC/CI (desktops)"
    echo "6) Archive: stow BSPWM/Polybar/Picom configs"
    echo "q) Quit"
    echo ""
    read -p "Select (space-separated): " -a choices

    for c in "${choices[@]}"; do
      case "$c" in
        1) bash "$SETUP_DIR/packages.sh" ;;
        2) bash "$SETUP_DIR/devtools.sh" ;;
        3) bash "$SETUP_DIR/firefox.sh" ;;
        4) install_cli_toolkit ;;
        5) bash "$SETUP_DIR/plasmoid-brillo.sh" ;;
        6) stow_archive ;;
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
      local name
      name=$(basename "$script")
      # Fail-safe: backup existing, don't overwrite silently
      if [ -f "$HOME/.local/bin/$name" ]; then
        # Only overwrite if source is newer or different
        if ! cmp -s "$script" "$HOME/.local/bin/$name"; then
          cp "$script" "$HOME/.local/bin/$name"
          chmod +x "$HOME/.local/bin/$name"
          echo "  - updated: $name"
        else
          echo "  - skipped (same): $name"
        fi
      else
        cp "$script" "$HOME/.local/bin/$name"
        chmod +x "$HOME/.local/bin/$name"
        echo "  - installed: $name"
      fi
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
