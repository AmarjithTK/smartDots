#!/bin/bash
# Development tools setup: ZSH, Neovim (NvChad), VSCodium, fonts
# Usage: bash devtools.sh

set -euo pipefail

echo "=== DevTools Setup ==="

# ─── ZSH + oh-my-zsh + powerlevel10k ─────────────────────────
setup_zsh() {
  echo "--- Setting up ZSH ---"
  sudo pacman -S --noconfirm zsh

  # Set ZSH as default shell
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)"
    echo "Default shell changed to ZSH. Log out and back in."
  fi

  # Install oh-my-zsh
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
  fi

  # Install powerlevel10k
  if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  fi

  # Ensure .zshrc sources .zshconfig
  if ! grep -q "zshconfig" "$HOME/.zshrc" 2>/dev/null; then
    {
      echo 'POWERLEVEL10K_DISABLE_CONFIGURATION_WIZARD=true'
      echo 'source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme'
      echo 'if [ -f ~/.zshconfig ]; then source ~/.zshconfig; fi'
    } >> "$HOME/.zshrc"
  fi

  echo "ZSH setup complete"
}

# ─── Neovim + NvChad ─────────────────────────────────────────
setup_nvim() {
  echo "--- Setting up Neovim ---"
  sudo pacman -S --noconfirm neovim

  # Fail-safe: backup existing config instead of nuking it
  if [ -d "$HOME/.config/nvim" ]; then
    echo "  ⚠️  Existing Neovim config found at ~/.config/nvim"
    read -p "     Overwrite? (y = replace, n = skip) [n]: " nvim_choice
    if [ "$nvim_choice" != "y" ] && [ "$nvim_choice" != "Y" ]; then
      echo "  ℹ️  Skipping NvChad install (existing config kept)"
      return
    fi
    local bak="$HOME/.config/nvim.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$HOME/.config/nvim" "$bak"
    echo "  📦 Backed up old config to $bak"
  fi

  rm -rf "$HOME/.local/state/nvim" "$HOME/.local/share/nvim"
  git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" --depth 1
  echo "NvChad installed. Run 'nvim' to complete setup."
}

# ─── VSCodium + extensions + settings ────────────────────────
setup_vscodium() {
  echo "--- Setting up VSCodium ---"
  if ! command -v codium &>/dev/null && command -v yay &>/dev/null; then
    yay -S vscodium-bin --noconfirm
  fi

  if command -v codium &>/dev/null; then
    codium --install-extension Equinusocio.vsc-material-theme --force
    codium --install-extension PKief.material-icon-theme --force
    codium --install-extension Dart-Code.flutter --force
    codium --install-extension vscodevim.vim --force

    mkdir -p "$HOME/.config/VSCodium/User"

    # Fail-safe: don't overwrite existing settings
    if [ -f "$HOME/.config/VSCodium/User/settings.json" ]; then
      echo "  ℹ️  VSCodium settings already exist — skipping overwrite"
      echo "  📍  Defaults available at: ~/smartDots/linux/setup/devtools.sh (search 'VSCodium')"
    else
      cat > "$HOME/.config/VSCodium/User/settings.json" <<'EOF'
{
  "editor.fontFamily": "Jetbrains Mono",
  "editor.fontSize": 17,
  "editor.fontLigatures": true,
  "workbench.colorTheme": "Material Theme Ocean High Contrast",
  "workbench.iconTheme": "material-icon-theme",
  "files.autoSave": "onFocusChange",
  "dart.flutterSdkPath": "~/flutter",
  "dart.sdkPath": "~/flutter/bin/cache/dart-sdk"
}
EOF
      echo "VSCodium configured"
    fi
  fi
}

# ─── Main ─────────────────────────────────────────────────────
setup_zsh
setup_nvim
setup_vscodium

echo ""
echo "=== DevTools complete ==="
echo "Next steps:"
echo "  1. Log out and back in to use ZSH"
echo "  2. Run 'nvim' to finish NvChad setup"
echo "  3. Open VSCodium to verify extensions"
