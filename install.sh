#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  smartDots — Unified Mega Installer
#  One script. One loop. Everything.
# ═══════════════════════════════════════════════════════════════
#  Usage:
#    bash <(curl -sL https://raw.githubusercontent.com/AmarjithTK/smartDots/main3/install.sh)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Config ──────────────────────────────────────────────────
BRANCH="main3"
REPO_SSH="git@github.com:AmarjithTK/smartDots.git"
REPO_HTTPS="https://github.com/AmarjithTK/smartDots.git"
DEST="$HOME/smartDots"
STATE_FILE="$HOME/.smartdots/install-state.txt"
SMARTDOTS_RC="$HOME/.smartdots/smartdots.sh"
REGISTRY_SRC="$DEST/cli-toolkit/registry.txt"

# ─── Colors ──────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m'
B='\033[1;37m' N='\033[0m'

# ═══════════════════════════════════════════════════════════════
#  STATE TRACKING
# ═══════════════════════════════════════════════════════════════

state_done() { mkdir -p "$HOME/.smartdots"; grep -qx "$1=done" "$STATE_FILE" 2>/dev/null; }
state_mark() { mkdir -p "$HOME/.smartdots"; sed -i "/^$1=/d" "$STATE_FILE" 2>/dev/null; echo "$1=done" >> "$STATE_FILE"; }
state_clear() { rm -f "$STATE_FILE"; }

menu_check() {
  if state_done "$1"; then echo "${G}✓${N}"; else echo " "; fi
}

# ═══════════════════════════════════════════════════════════════
#  UI HELPERS
# ═══════════════════════════════════════════════════════════════

box() {
  local t="$1"; local len=${#t}; local line
  line=$(printf '═%.0s' $(seq 1 $((len+2))))
  echo ""; echo "${C}╔${line}╗${N}"; echo "${C}║ ${B}${t}${N} ${C}║${N}"; echo "${C}╚${line}╝${N}"; echo ""
}

info()  { echo -e "  ${C}ℹ️${N}  $1"; }
ok()    { echo -e "  ${G}✅${N} $1"; }
warn()  { echo -e "  ${Y}⚠️${N}  $1"; }
fail()  { echo -e "  ${R}❌${N} $1"; }

prompt_yes() {
  local d="${2:-y}"
  read -p "  ${1} [${d}]: " r; r="${r:-$d}"
  [[ "$r" == "y" || "$r" == "Y" || "$r" == "yes" ]]
}

print_key_box() {
  local f="$1"; local kt kd kc
  kt=$(awk '{print $1}' "$f"); kd=$(awk '{print $2}' "$f"); kc=$(awk '{print $3}' "$f")
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════╗"
  echo "║                     YOUR SSH PUBLIC KEY                             ║"
  echo "╠══════════════════════════════════════════════════════════════════════╣"
  echo "║                                                                      ║"
  echo "║  ${kt} ${kd}  ║"
  echo "║  ${kc}"
  echo "║                                                                      ║"
  echo "╚══════════════════════════════════════════════════════════════════════╝"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: CLONE REPO (SSH-first, HTTPS fallback)
# ═══════════════════════════════════════════════════════════════

clone_repo() {
  box "Cloning smartDots"

  # Already cloned
  if [[ -d "$DEST/.git" ]]; then
    info "Already cloned at $DEST. Pulling updates..."
    cd "$DEST" && git pull origin "$BRANCH" 2>/dev/null && ok "Updated" || warn "Pull failed"
    return 0
  fi

  # Try SSH first
  if git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_SSH" "$DEST" 2>/dev/null; then
    ok "Cloned via SSH"; return 0
  fi

  # SSH failed — diagnose
  warn "SSH clone failed"
  ping -c 1 github.com &>/dev/null || { fail "Cannot reach github.com"; exit 1; }

  local keyf=""
  for f in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/id_ecdsa.pub"; do
    [[ -f "$f" ]] && { keyf="$f"; break; }
  done

  if [[ -z "$keyf" ]]; then
    echo ""
    info "No SSH key found."
    if prompt_yes "Generate a new ed25519 SSH key?" "y"; then
      mkdir -p "$HOME/.ssh"
      ssh-keygen -t ed25519 -C "${USER}@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N "" 2>/dev/null
      keyf="$HOME/.ssh/id_ed25519.pub"
      ok "Key generated"
    else
      info "Using HTTPS instead"
      git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_HTTPS" "$DEST"
      ok "Cloned via HTTPS"; return 0
    fi
  fi

  print_key_box "$keyf"

  # Try gh CLI upload
  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    info "Uploading key via gh CLI..."
    gh ssh-key add "$keyf" --title "smartdots-$(hostname)-$(date +%Y%m%d)" 2>/dev/null && {
      ok "Key uploaded"; sleep 3
      git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_SSH" "$DEST" 2>/dev/null && { ok "Cloned via SSH"; return 0; }
    }
  fi

  # Manual instructions
  echo ""
  echo "  Add this key to GitHub: https://github.com/settings/ssh/new"
  echo "  Then press ENTER to retry, or type 'https' for HTTPS fallback"
  read -p "  [ENTER/https]: " r
  if [[ "$r" == "https" ]]; then
    git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_HTTPS" "$DEST"
    ok "Cloned via HTTPS"
  else
    git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_SSH" "$DEST" 2>/dev/null && ok "Cloned via SSH" || {
      warn "SSH still failing, falling back to HTTPS"
      git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_HTTPS" "$DEST"
      ok "Cloned via HTTPS"
    }
  fi
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: INSTALL BASE PACKAGES
# ═══════════════════════════════════════════════════════════════

install_base_packages() {
  box "Installing Base Packages"
  [[ $(id -u) -eq 0 ]] && { fail "Don't run as root"; return 1; }

  sudo pacman -S --noconfirm --needed \
    base-devel git stow curl wget \
    zsh kitty rofi dunst feh \
    brightnessctl ddcutil redshift xclip \
    pulseaudio pavucontrol \
    neovim python python-pip python-virtualenvwrapper \
    nodejs npm distrobox \
    xdotool wmctrl xprintidle zenity jq \
    noto-fonts noto-fonts-emoji \
    ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-fira-code \
    github-cli 2>&1 | tail -1

  # DDC/CI kernel module
  sudo modprobe i2c-dev 2>/dev/null || true
  if ! grep -q i2c-dev /etc/modules-load.d/i2c-dev.conf 2>/dev/null; then
    echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null
  fi
  sudo usermod -aG i2c "$USER" 2>/dev/null || true

  ok "Base packages installed"
  state_mark "base_packages"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: DEV TOOLS (ZSH + OH-MY-ZSH + P10K + NVCHAD + VSCODIUM)
# ═══════════════════════════════════════════════════════════════

install_dev_tools() {
  box "Installing Dev Tools"

  # ── ZSH + oh-my-zsh + powerlevel10k ──────────────────────
  info "Setting up ZSH..."
  sudo pacman -S --noconfirm zsh 2>&1 | tail -1

  if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s "$(which zsh)" 2>/dev/null && warn "Default shell changed to ZSH — log out/in"
  fi

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null && ok "oh-my-zsh installed"
  else
    info "oh-my-zsh already installed"
  fi

  if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" 2>/dev/null && ok "powerlevel10k installed"
  else
    info "powerlevel10k already installed"
  fi

  # ── Ensure .zshrc sources .zshconfig (MERGE, NOT REPLACE) ──
  if [[ ! -f "$HOME/.zshrc" ]]; then
    cat > "$HOME/.zshrc" <<'EOF'
# Default .zshrc — smartDots managed
POWERLEVEL10K_DISABLE_CONFIGURATION_WIZARD=true
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
[ -f "$HOME/.zshconfig" ] && . "$HOME/.zshconfig"
EOF
    ok "Created .zshrc (sources .zshconfig)"
  elif ! grep -q "zshconfig" "$HOME/.zshrc" 2>/dev/null; then
    {
      echo ""
      echo "# smartDots: load custom config"
      echo '[ -f "$HOME/.zshconfig" ] && . "$HOME/.zshconfig"'
    } >> "$HOME/.zshrc"
    ok "Appended .zshconfig source line to .zshrc (existing config preserved)"
  else
    info ".zshrc already sources .zshconfig"
  fi

  # ── Neovim + NvChad ──────────────────────────────────────
  info "Setting up Neovim..."
  sudo pacman -S --noconfirm neovim 2>&1 | tail -1

  if [[ -d "$HOME/.config/nvim" ]]; then
    warn "Existing Neovim config found"
    if prompt_yes "Replace with NvChad? (your config will be backed up)" "n"; then
      local bak="$HOME/.config/nvim.bak.$(date +%Y%m%d-%H%M%S)"
      mv "$HOME/.config/nvim" "$bak" && ok "Backed up → $bak"
      rm -rf "$HOME/.local/state/nvim" "$HOME/.local/share/nvim"
      git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" --depth 1 2>/dev/null && ok "NvChad installed"
    else
      info "Skipping NvChad"
    fi
  else
    git clone https://github.com/NvChad/NvChad "$HOME/.config/nvim" --depth 1 2>/dev/null && ok "NvChad installed"
  fi

  # ── VSCodium (AUR) ───────────────────────────────────────
  if command -v yay &>/dev/null; then
    if ! command -v codium &>/dev/null; then
      yay -S vscodium-bin --noconfirm 2>/dev/null | tail -1 && ok "VSCodium installed"
    else
      info "VSCodium already installed"
    fi

    if command -v codium &>/dev/null; then
      codium --install-extension Equinusocio.vsc-material-theme --force &>/dev/null
      codium --install-extension PKief.material-icon-theme --force &>/dev/null
      codium --install-extension vscodevim.vim --force &>/dev/null
      mkdir -p "$HOME/.config/VSCodium/User"
      if [[ ! -f "$HOME/.config/VSCodium/User/settings.json" ]]; then
        cat > "$HOME/.config/VSCodium/User/settings.json" <<'EOF'
{
  "editor.fontFamily": "Jetbrains Mono",
  "editor.fontSize": 17,
  "editor.fontLigatures": true,
  "workbench.colorTheme": "Material Theme Ocean High Contrast",
  "workbench.iconTheme": "material-icon-theme",
  "files.autoSave": "onFocusChange"
}
EOF
        ok "VSCodium settings configured"
      else
        info "VSCodium settings exist — skipping"
      fi
    fi
  else
    warn "yay not found — install manually: yay -S vscodium-bin"
  fi

  ok "Dev tools setup complete"
  state_mark "dev_tools"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: CLI TOOLKIT (60+ ALIASES + HELPER COMMAND)
# ═══════════════════════════════════════════════════════════════

install_cli_toolkit() {
  box "Installing CLI Toolkit"

  local smartdots_dir="$HOME/.smartdots"
  mkdir -p "$smartdots_dir"

  # Copy registry
  if [[ -f "$REGISTRY_SRC" ]]; then
    cp "$REGISTRY_SRC" "$smartdots_dir/registry.txt"
    local count
    count=$(grep -c '^[a-z]' "$smartdots_dir/registry.txt" 2>/dev/null || echo 0)
    ok "Copied ${count}+ aliases to $smartdots_dir/registry.txt"
  else
    fail "registry.txt not found — skipping"
    return 1
  fi

  # Copy smartdots.sh
  if [[ -f "$DEST/cli-toolkit/smartdots.sh" ]]; then
    cp "$DEST/cli-toolkit/smartdots.sh" "$SMARTDOTS_RC"
    ok "Copied smartdots.sh"
  else
    # Embedded fallback — write it directly
    cat > "$SMARTDOTS_RC" <<'SHEOF'
#!/bin/sh
SMARTDOTS="${SMARTDOTS_HOME:-$HOME/.smartdots}"
REGISTRY="$SMARTDOTS/registry.txt"
if [ -f "$REGISTRY" ]; then
  while IFS='|' read -r category alias_name command; do
    case "$category" in ''|\#*) continue;; esac
    alias "$alias_name"="$command" 2>/dev/null || true
  done < "$REGISTRY"
fi
helper() {
  _reg="$REGISTRY"; _filter="$1"
  if [ ! -f "$_reg" ]; then echo "Registry not found"; return 1; fi
  if [ -z "$_filter" ]; then
    awk -F'|' '/^[a-z]/ { if ($1 != p) { print "\n=== " toupper(substr($1,1,1)) substr($1,2) " ==="; p=$1 } printf "  %-12s %s\n", $2, $3 }' "$_reg"
  else
    awk -F'|' -v f="$_filter" '/^[a-z]/ && tolower($0) ~ tolower(f) { if ($1 != p) { print "\n=== " toupper(substr($1,1,1)) substr($1,2) " ==="; p=$1 } printf "  %-12s %s\n", $2, $3 }' "$_reg"
  fi
}
SHEOF
    ok "Created smartdots.sh (embedded fallback)"
  fi

  # Detect shell and add source line
  local rcfile=""
  case "$(basename "${SHELL:-bash}")" in
    zsh) rcfile="$HOME/.zshrc" ;;
    bash) rcfile="$HOME/.bashrc" ;;
    *) rcfile="$HOME/.profile" ;;
  esac

  local source_line=". \"\$HOME/.smartdots/smartdots.sh\""
  if ! grep -q "smartdots.sh" "$rcfile" 2>/dev/null; then
    { echo ""; echo "# smartDots CLI Toolkit"; echo "$source_line"; } >> "$rcfile"
    ok "Added source line to $rcfile"
  else
    info "smartdots.sh already sourced in $rcfile"
  fi

  # Source now
  . "$SMARTDOTS_RC" 2>/dev/null || true

  # Print sample
  echo ""
  echo "  ${C}Available commands:${N}"
  echo "    ${B}helper${N}            List all ${count}+ aliases"
  echo "    ${B}helper git${N}        Show Git aliases"
  echo "    ${B}helper flutter${N}    Show Flutter aliases"
  echo "    ${B}helper build${N}      Search for 'build'"
  echo "    ${B}gs${N}               → git status"
  echo "    ${B}gcap${N}             → git add + commit + push"
  echo "    ${B}fpg${N}              → flutter pub get"
  echo "    ${B}nd${N}               → npm run dev"
  echo ""

  state_mark "cli_toolkit"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: INSTALL BRILLO KDE WIDGET
# ═══════════════════════════════════════════════════════════════

install_brillo() {
  box "Installing Brillo KDE Brightness Widget"

  if ! command -v plasmashell &>/dev/null; then
    warn "KDE Plasma not detected — skipping Brillo"
    return 1
  fi

  local plasmoid_id="org.amarjithtk.brillo"
  local src="$DEST/linux/stow/plasmoids/$plasmoid_id"
  local dst="$HOME/.local/share/plasma/plasmoids/$plasmoid_id"

  # Copy plasmoid files
  mkdir -p "$dst/contents/ui"
  if [[ -f "$src/metadata.json" ]]; then
    cp "$src/metadata.json" "$dst/"
    cp "$src/contents/ui/main.qml" "$dst/contents/ui/"
    ok "Plasmoid files installed"
  else
    fail "Plasmoid source not found at $src"
    return 1
  fi

  # Add to KDE panel
  local panel_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
  if grep -q "$plasmoid_id" "$panel_config" 2>/dev/null; then
    info "Brillo already in panel"
  else
    local panel_id=""
    # Find panel containment
    panel_id=$(python3 -c "
import configparser, re
c = configparser.ConfigParser()
c.read('$panel_config')
for s in c.sections():
    if s.startswith('Containements]['):
        try:
            if c.get(s, 'plugin') == 'org.kde.panel':
                print(re.search(r'Containments\]\[(\d+)\]', s).group(1))
        except: pass
" 2>/dev/null)

    if [[ -z "$panel_id" ]]; then
      panel_id=$(grep -B5 "formfactor=2" "$panel_config" 2>/dev/null | grep -oP 'Containments\]\[\K\d+' | head -1)
    fi

    if [[ -n "$panel_id" ]]; then
      local applet_id
      applet_id=$(date +%s)
      if command -v kwriteconfig6 &>/dev/null; then
        kwriteconfig6 --file "$panel_config" --group "Containments][$panel_id][Applets][$applet_id" --key "plugin" "$plasmoid_id"
      else
        echo "" >> "$panel_config"
        echo "[Containments][$panel_id][Applets][$applet_id]" >> "$panel_config"
        echo "plugin=$plasmoid_id" >> "$panel_config"
      fi
      ok "Brillo added to KDE panel"
    else
      warn "Could not detect panel — add Brillo manually: right-click panel → Add Widgets"
    fi
  fi

  # Restore brightness on login
  local autostart_dst="$HOME/.config/autostart"
  mkdir -p "$autostart_dst"
  cat > "$autostart_dst/restore-brightness.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Restore Display Brightness
Exec=$HOME/.local/bin/display-manager brightness restore
Terminal=false
X-KDE-autostart-phase=2
EOF
  ok "Brightness restore autostart configured"

  # Save current brightness
  if command -v display-manager &>/dev/null; then
    display-manager brightness save 2>/dev/null || true
  fi

  # Restart Plasma shell
  warn "Restarting Plasma shell in 3s..."
  sleep 3
  if command -v kquitapp6 &>/dev/null; then
    kquitapp6 plasmashell 2>/dev/null || true
    sleep 2
    kstart6 plasmashell &>/dev/null &
  elif command -v kquitapp5 &>/dev/null; then
    kquitapp5 plasmashell 2>/dev/null || true
    sleep 2
    kstart5 plasmashell &>/dev/null &
  fi

  ok "Brillo installation complete"
  state_mark "brillo"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: STOW DOTFILES (safe — backups existing files)
# ═══════════════════════════════════════════════════════════════

stow_dotfiles() {
  box "Stowing Dotfiles"

  local ts
  ts=$(date +%Y%m%d-%H%M%S)

  # Stow non-shell packages (kitty, rofi, dunst, firefox, plasma-autostart)
  for pkg in kitty rofi dunst firefox plasma-autostart; do
    local dir="$DEST/linux/stow/$pkg"
    [[ ! -d "$dir" ]] && continue

    # Backup existing
    while IFS= read -r -d '' rel; do
      local t="$HOME/$rel"
      if [[ -f "$t" && ! -L "$t" ]]; then
        mv "$t" "$t.bak.$ts"
        warn "Backed up: ~/$rel → ~/$rel.bak.$ts"
      fi
    done < <(cd "$dir" && find . -type f -print0 2>/dev/null)

    cd "$DEST" && stow -d "linux/stow" -t "$HOME" "$pkg" 2>/dev/null && ok "Stowed: $pkg"
  done

  # Stow .zshconfig only (NOT .zshrc)
  if [[ -d "$DEST/linux/stow/shell" ]]; then
    while IFS= read -r -d '' rel; do
      [[ "$rel" == ".zshrc" ]] && continue
      local t="$HOME/$rel"
      if [[ -f "$t" && ! -L "$t" ]]; then
        mv "$t" "$t.bak.$ts"
        warn "Backed up: ~/$rel → ~/$rel.bak.$ts"
      fi
    done < <(cd "$DEST/linux/stow/shell" && find . -type f -print0 2>/dev/null)
    cd "$DEST" && stow -d "linux/stow" -t "$HOME" "shell" 2>/dev/null && ok "Stowed: shell/.zshconfig"
  fi

  # Shared git config (no-clobber)
  cp -n "$DEST/shared/git/.gitconfig" "$HOME/" 2>/dev/null || info ".gitconfig exists — skipped"
  cp -n "$DEST/shared/git/.gitignore_global" "$HOME/" 2>/dev/null || info ".gitignore_global exists — skipped"

  ok "Dotfiles stowed"
  state_mark "stow_dotfiles"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: INSTALL HELPER SCRIPTS
# ═══════════════════════════════════════════════════════════════

install_helper_scripts() {
  box "Installing Helper Scripts → ~/.local/bin"

  mkdir -p "$HOME/.local/bin"

  local count=0 updated=0
  for script in "$DEST/linux/bin/"*; do
    [[ ! -f "$script" ]] && continue
    local name
    name=$(basename "$script")
    local target="$HOME/.local/bin/$name"

    if [[ -f "$target" ]]; then
      if cmp -s "$script" "$target"; then
        ((count++)); continue
      fi
    fi

    cp "$script" "$target"
    chmod +x "$target"
    ((updated++))
    ((count++))
  done

  ok "$count scripts available ($updated updated)"

  # Ensure ~/.local/bin is in PATH
  local rcfile="$HOME/.zshconfig"
  if [[ -f "$rcfile" ]] && ! grep -q ".local/bin" "$rcfile" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rcfile"
    export PATH="$HOME/.local/bin:$PATH"
    ok "Added ~/.local/bin to PATH"
  fi

  # List available scripts
  echo ""
  echo "  ${C}Available:${N}"
  for s in "$HOME/.local/bin/"*; do
    local n; n=$(basename "$s")
    echo "    ${B}$n${N}"
  done | column
  echo ""

  state_mark "helper_scripts"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: FIREFOX THEME
# ═══════════════════════════════════════════════════════════════

setup_firefox_theme() {
  box "Setting up Firefox Theme"

  if ! command -v firefox &>/dev/null; then
    if prompt_yes "Firefox not installed. Install it?" "y"; then
      sudo pacman -S firefox --noconfirm
    else
      warn "Skipping Firefox theme"
      return 1
    fi
  fi

  local userchrome="$HOME/.config/firefox/userChrome.css"
  if [[ ! -f "$userchrome" ]]; then
    fail "userChrome.css not found at $userchrome — stow dotfiles first"
    return 1
  fi

  local linked=0
  while IFS= read -r profile; do
    local chrome="$profile/chrome"
    mkdir -p "$chrome"
    ln -sf "$userchrome" "$chrome/userChrome.css"
    ((linked++))
  done < <(find "$HOME/.mozilla/firefox/" -maxdepth 1 -name "*.default*" -type d 2>/dev/null)

  if [[ $linked -gt 0 ]]; then
    ok "Linked userChrome.css to $linked Firefox profile(s)"
  else
    warn "No Firefox profiles found — run Firefox once first"
  fi

  state_mark "firefox_theme"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: SSH KEY SETUP
# ═══════════════════════════════════════════════════════════════

setup_ssh_key() {
  box "SSH Key Setup"

  local keyf=""
  for f in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/id_ecdsa.pub"; do
    [[ -f "$f" ]] && { keyf="$f"; break; }
  done

  if [[ -n "$keyf" ]]; then
    ok "SSH key found: $keyf"
  else
    if prompt_yes "No SSH key found. Generate ed25519?" "y"; then
      mkdir -p "$HOME/.ssh"
      ssh-keygen -t ed25519 -C "${USER}@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N "" 2>/dev/null
      keyf="$HOME/.ssh/id_ed25519.pub"
      ok "Generated: $keyf"
    else
      warn "Skipping SSH key setup"
      return 1
    fi
  fi

  print_key_box "$keyf"

  # Test connection
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    ok "SSH key already added to GitHub!"
    state_mark "ssh_key"
    return 0
  fi

  # Try gh CLI
  if command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
    if prompt_yes "Upload key to GitHub via gh CLI?" "y"; then
      gh ssh-key add "$keyf" --title "smartdots-$(hostname)-$(date +%Y%m%d)" && ok "Key uploaded!"
      state_mark "ssh_key"
      return 0
    fi
  fi

  # Manual
  echo ""
  echo "  ${C}Add this key to GitHub:${N}"
  echo "    ${B}https://github.com/settings/ssh/new${N}"
  echo ""
  echo "  Or use gh CLI:"
  echo "    ${B}gh auth login${N}"
  echo "    ${B}gh ssh-key add $keyf${N}"
  echo ""

  state_mark "ssh_key"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: UPDATE SYSTEM
# ═══════════════════════════════════════════════════════════════

update_system() {
  box "Updating System"

  sudo pacman -Syu 2>&1 | tail -3

  command -v flutter &>/dev/null && flutter upgrade 2>/dev/null || true
  command -v npm &>/dev/null && npm update -g 2>/dev/null || true
  command -v rustup &>/dev/null && rustup update 2>/dev/null || true
  command -v flatpak &>/dev/null && flatpak update -y 2>/dev/null || true

  ok "System updated"
  state_mark "system_updated"
}

# ═══════════════════════════════════════════════════════════════
#  FEATURE: INSTALL ALL (in dependency order)
# ═══════════════════════════════════════════════════════════════

install_all() {
  box "Installing EVERYTHING"
  clone_repo
  install_base_packages
  install_dev_tools
  install_cli_toolkit
  stow_dotfiles
  install_helper_scripts
  setup_firefox_theme
  install_brillo
  setup_ssh_key
  update_system
  ok "All tasks completed!"
}

# ═══════════════════════════════════════════════════════════════
#  MENU
# ═══════════════════════════════════════════════════════════════

menu() {
  while true; do
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║           ${B}smartDots — Mega Installer${N}              ║"
    echo "╠══════════════════════════════════════════════════════╣"
    printf "║  ${B}1${N}) Base packages        [%s]                      ║\n" "$(menu_check base_packages)"
    printf "║  ${B}2${N}) Dev tools (ZSH+Nvim)  [%s]                      ║\n" "$(menu_check dev_tools)"
    printf "║  ${B}3${N}) CLI Toolkit 60+ aliases[%s]                      ║\n" "$(menu_check cli_toolkit)"
    printf "║  ${B}4${N}) Brillo KDE widget     [%s]                      ║\n" "$(menu_check brillo)"
    printf "║  ${B}5${N}) Stow dotfiles         [%s]                      ║\n" "$(menu_check stow_dotfiles)"
    printf "║  ${B}6${N}) Helper scripts        [%s]                      ║\n" "$(menu_check helper_scripts)"
    printf "║  ${B}7${N}) Firefox theme         [%s]                      ║\n" "$(menu_check firefox_theme)"
    printf "║  ${B}8${N}) SSH key setup         [%s]                      ║\n" "$(menu_check ssh_key)"
    printf "║  ${B}9${N}) Update system         [%s]                      ║\n" "$(menu_check system_updated)"
    echo "║                                              ║"
    echo "║  ${B}a${N}) Install ALL                         ║"
    echo "║  ${B}r${N}) Reset all states                    ║"
    echo "║  ${B}q${N}) Quit                               ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo "  Repo: $DEST"
    echo ""
    read -p "  Select (space-separated, e.g. '1 3 5'): " -a choices

    for c in "${choices[@]}"; do
      case "$c" in
        1) install_base_packages ;;
        2) install_dev_tools ;;
        3) install_cli_toolkit ;;
        4) install_brillo ;;
        5) stow_dotfiles ;;
        6) install_helper_scripts ;;
        7) setup_firefox_theme ;;
        8) setup_ssh_key ;;
        9) update_system ;;
        a|A) install_all ;;
        r|R) state_clear; ok "States reset" ;;
        q|Q) echo ""; ok "Done!"; exit 0 ;;
        *) warn "Unknown option: $c" ;;
      esac
    done
  done
}

# ═══════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════

main() {
  box "smartDots Unified Installer"
  echo "  Branch: ${B}$BRANCH${N}"
  echo "  Repo:   ${B}$DEST${N}"
  echo ""

  # If not cloned yet, do it first
  if [[ ! -d "$DEST/.git" ]]; then
    clone_repo
  fi

  # Enter menu
  menu
}

main "$@"
