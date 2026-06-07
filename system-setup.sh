#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  system-setup — base packages, configs, git/ssh, TLP, updates
#  ═══════════════════════════════════════════════════════════════════
#  A simple while-loop menu for setting up Arch Linux.
#
#  USAGE:
#    bash system-setup.sh
#  ═══════════════════════════════════════════════════════════════════

# ── Style ─────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
warn() { echo -e "  ${YELLOW}→${RESET} $1"; }
fail() { echo -e "  ${RED}✗${RESET} $1"; }
info() { echo -e "  ${CYAN}i${RESET} $1"; }

# ── State tracking ────────────────────────────────────────────────
STATE_FILE="$HOME/.aliasmanager/setup-state.txt"
state_done() { grep -qx "$1=done" "$STATE_FILE" 2>/dev/null; }
state_mark() { mkdir -p "$HOME/.aliasmanager"; sed -i "/^$1=/d" "$STATE_FILE" 2>/dev/null; echo "$1=done" >> "$STATE_FILE"; }
check() { if state_done "$1"; then echo "${GREEN}✓${RESET}"; else echo " "; fi; }

# ═══════════════════════════════════════════════════════════════════
#  1. BASE PACKAGES
#  ═══════════════════════════════════════════════════════════════════

install_base_packages() {
  echo ""
  info "Installing base packages..."

  sudo pacman -Syy --noconfirm
  sudo pacman -S --noconfirm --needed \
    base-devel git curl wget \
    brightnessctl ddcutil xclip \
    neovim python python-pip \
    nodejs npm distrobox \
    docker docker-compose \
    noto-fonts ttf-jetbrains-mono ttf-jetbrains-mono-nerd \
    ttf-fira-code ttf-firacode-nerd \
    github-cli neofetch htop tree \
    xprintidle zenity jq \
    --noconfirm 2>&1 | tail -1

  if ! command -v yay &>/dev/null; then
    warn "yay not found. Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm) 2>/dev/null
    rm -rf /tmp/yay
    ok "yay installed"
  fi

  ok "Base packages installed"
  state_mark "base_packages"
}

# ═══════════════════════════════════════════════════════════════════
#  2. CONFIG FILES
#  ═══════════════════════════════════════════════════════════════════

install_configs() {
  echo ""
  info "Installing config files..."

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  for f in .gitconfig .gitignore_global; do
    if [ -f "$script_dir/$f" ]; then
      cp -n "$script_dir/$f" "$HOME/" 2>/dev/null && ok "Copied $f to ~/" || info "$f already exists — skipped"
    fi
  done

  git config --global init.defaultBranch main 2>/dev/null || true
  ok "Config files installed"
  state_mark "configs"
}

# ═══════════════════════════════════════════════════════════════════
#  3. GIT + SSH KEY
#  ═══════════════════════════════════════════════════════════════════

setup_git_ssh() {
  echo ""
  info "Setting up Git + SSH..."

  local name email
  name=$(git config user.name 2>/dev/null || echo "")
  email=$(git config user.email 2>/dev/null || echo "")

  if [ -z "$name" ]; then
    read -p "  Git user.name: " name
    git config --global user.name "$name"
  fi
  if [ -z "$email" ]; then
    read -p "  Git user.email: " email
    git config --global user.email "$email"
  fi
  ok "Git configured: $name <$email>"

  local keyfile="$HOME/.ssh/id_ed25519"
  if [ -f "$keyfile.pub" ]; then
    ok "SSH key found: $keyfile.pub"
  else
    if command -v ssh-keygen &>/dev/null; then
      mkdir -p "$HOME/.ssh"
      ssh-keygen -t ed25519 -C "$email" -f "$keyfile" -N "" 2>/dev/null
      ok "SSH key generated: $keyfile.pub"
    fi
  fi

  if [ -f "$keyfile.pub" ]; then
    echo ""
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │  YOUR SSH PUBLIC KEY                                │"
    echo "  │  Add to GitHub: https://github.com/settings/keys    │"
    echo "  ├─────────────────────────────────────────────────────┤"
    cat "$keyfile.pub" | sed 's/^/  │  /'
    echo "  └─────────────────────────────────────────────────────┘"
    echo ""

    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
      ok "SSH key authenticated with GitHub"
    else
      warn "SSH key not added to GitHub yet"
    fi

    if command -v xclip &>/dev/null; then
      xclip -selection clipboard < "$keyfile.pub"
      ok "Public key copied to clipboard"
    fi
  fi

  state_mark "git_ssh"
}

# ═══════════════════════════════════════════════════════════════════
#  4. LAPTOP POWER (TLP)
#  ═══════════════════════════════════════════════════════════════════

setup_laptop_power() {
  echo ""
  info "Setting up laptop power management (TLP)..."
  sudo pacman -Syy --noconfirm
  sudo pacman -S --noconfirm tlp tlp-rdw 2>&1 | tail -1
  sudo systemctl enable tlp.service 2>/dev/null
  sudo systemctl enable NetworkManager-dispatcher.service 2>/dev/null
  sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket 2>/dev/null
  ok "TLP enabled"
  state_mark "laptop_power"
}

# ═══════════════════════════════════════════════════════════════════
#  5. SYSTEM UPDATE
#  ═══════════════════════════════════════════════════════════════════

system_update() {
  echo ""
  info "Updating system..."
  sudo pacman -Syu --noconfirm 2>&1 | tail -3
  ok "System updated"
  state_mark "system_updated"
}

# ═══════════════════════════════════════════════════════════════════
#  INSTALL EVERYTHING
#  ═══════════════════════════════════════════════════════════════════

install_all() {
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  Installing EVERYTHING                              │"
  echo "  └─────────────────────────────────────────────────────┘"
  install_base_packages
  install_configs
  setup_git_ssh
  setup_laptop_power
  system_update
  ok "All done!"
}

# ═══════════════════════════════════════════════════════════════════
#  MENU — while true loop
#  ═══════════════════════════════════════════════════════════════════

while true; do
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  SYSTEM SETUP                                       │"
  echo "  ├─────────────────────────────────────────────────────┤"
  printf "  │  %s1%s) Base packages        [%s]                   │\n" "$BOLD" "$RESET" "$(check base_packages)"
  printf "  │  %s2%s) Config files         [%s]                   │\n" "$BOLD" "$RESET" "$(check configs)"
  printf "  │  %s3%s) Git + SSH key        [%s]                   │\n" "$BOLD" "$RESET" "$(check git_ssh)"
  printf "  │  %s4%s) Laptop power (TLP)   [%s]                   │\n" "$BOLD" "$RESET" "$(check laptop_power)"
  printf "  │  %s5%s) System update        [%s]                   │\n" "$BOLD" "$RESET" "$(check system_updated)"
  echo "  │                                              │"
  echo "  │  a) Install ALL                              │"
  echo "  │  q) Quit                                     │"
  echo "  └─────────────────────────────────────────────────────┘"
  echo ""
  read -p "  Select (e.g. '1 3 5' or 'a'): " -a choices

  for c in "${choices[@]}"; do
    case "$c" in
      1) install_base_packages ;;
      2) install_configs ;;
      3) setup_git_ssh ;;
      4) setup_laptop_power ;;
      5) system_update ;;
      a|A) install_all ;;
      q|Q) echo ""; echo "  Done."; exit 0 ;;
      *) warn "Unknown: $c" ;;
    esac
  done
done
