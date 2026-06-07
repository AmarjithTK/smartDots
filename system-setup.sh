#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  system-setup — system update, packages, configs, git/ssh
#  ═══════════════════════════════════════════════════════════════════
#  A simple while-loop menu for setting up Arch Linux.
#
#  USAGE:
#    bash system-setup.sh
#  ═══════════════════════════════════════════════════════════════════

# ── Style ─────────────────────────────────────────────────────────
BOLD=$'\033[1m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

ok()   { echo "  ${GREEN}✓${RESET} $1"; }
warn() { echo "  ${YELLOW}→${RESET} $1"; }
fail() { echo "  ${RED}✗${RESET} $1"; }
info() { echo "  ${CYAN}i${RESET} $1"; }

# ── State tracking ────────────────────────────────────────────────
STATE_FILE="$HOME/.aliasmanager/setup-state.txt"
state_done() { grep -qx "$1=done" "$STATE_FILE" 2>/dev/null; }
state_mark() { mkdir -p "$HOME/.aliasmanager"; sed -i "/^$1=/d" "$STATE_FILE" 2>/dev/null; echo "$1=done" >> "$STATE_FILE"; }
check() { if state_done "$1"; then echo "${GREEN}✓${RESET}"; else echo " "; fi; }

# ═══════════════════════════════════════════════════════════════════
#  1. SYSTEM UPDATE (always do this first)
#  ═══════════════════════════════════════════════════════════════════

system_update() {
  echo ""
  info "Updating system..."
  sudo pacman -Syu --noconfirm 2>&1 | tail -3
  ok "System updated"
  state_mark "system_updated"
}

# ═══════════════════════════════════════════════════════════════════
#  2. BASE PACKAGES
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
#  3. CONFIG FILES
#  ═══════════════════════════════════════════════════════════════════

install_configs() {
  echo ""
  info "Installing config files..."
  echo "  ┌─────────────────────────────────────────────────────────┐"
  echo "  │  .gitconfig        → Git user name/email + aliases        │"
  echo "  │  .gitignore_global → Global gitignore (Node/Python/...)  │"
  echo "  └─────────────────────────────────────────────────────────┘"

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  for f in .gitconfig .gitignore_global; do
    if [ -f "$script_dir/$f" ]; then
      if [ -f "$HOME/$f" ]; then
        info "$f already exists in ~/ — not overwritten"
      else
        cp "$script_dir/$f" "$HOME/" && ok "Copied $f → ~/$f"
      fi
    fi
  done

  # Ensure critical git settings are always applied (even if config already existed)
  git config --global core.excludesfile ~/.gitignore_global 2>/dev/null || true
  git config --global init.defaultBranch main 2>/dev/null || true
  ok "Config files installed"
  state_mark "configs"
}

# ═══════════════════════════════════════════════════════════════════
#  4. GIT + SSH KEY
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

  # Detect any existing SSH key (ed25519, rsa, ecdsa)
  local keyfile=""
  for candidate in id_ed25519 id_rsa id_ecdsa id_dsa; do
    if [ -f "$HOME/.ssh/${candidate}.pub" ]; then
      keyfile="$HOME/.ssh/$candidate"
      break
    fi
  done

  if [ -n "$keyfile" ]; then
    ok "SSH key found: $keyfile"
  else
    # No key exists — generate ed25519
    keyfile="$HOME/.ssh/id_ed25519"
    if command -v ssh-keygen &>/dev/null; then
      mkdir -p "$HOME/.ssh"
      ssh-keygen -t ed25519 -C "$email" -f "$keyfile" -N "" 2>/dev/null
      ok "SSH key generated: $keyfile"
    else
      warn "ssh-keygen not found — cannot generate SSH key"
    fi
  fi

  # Sync sshCommand in .gitconfig to match the actual key
  if [ -n "$keyfile" ] && [ -f "$keyfile" ]; then
    git config --global core.sshCommand "ssh -i $keyfile -o IdentitiesOnly=yes"
  fi

  if [ -f "$keyfile.pub" ]; then
    echo ""
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │  YOUR SSH PUBLIC KEY                                │"
    echo "  │  Add to GitHub: https://github.com/settings/keys    │"
    echo "  ├─────────────────────────────────────────────────────┤"
    sed 's/^/  │  /' "$keyfile.pub"
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
#  INSTALL EVERYTHING
#  ═══════════════════════════════════════════════════════════════════

install_all() {
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  Installing EVERYTHING                              │"
  echo "  └─────────────────────────────────────────────────────┘"
  system_update
  install_base_packages
  install_configs
  setup_git_ssh
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
  echo "  │                                                     │"
  echo "  │  ${BOLD}1${RESET}) System update                        [$(check system_updated)]         │"
  echo "  │  ${BOLD}2${RESET}) Base packages                        [$(check base_packages)]         │"
  echo "  │  ${BOLD}3${RESET}) Config files                         [$(check configs)]         │"
  echo "  │       • .gitconfig (user/aliases)                   │"
  echo "  │       • .gitignore_global (Node/Python/Rust/...)    │"
  echo "  │  ${BOLD}4${RESET}) Git + SSH key                        [$(check git_ssh)]         │"
  echo "  │                                                     │"
  echo "  │  ${BOLD}a${RESET}) Install ALL                                     │"
  echo "  │  ${BOLD}q${RESET}) Quit                                            │"
  echo "  │                                                     │"
  echo "  └─────────────────────────────────────────────────────┘"
  echo ""
  read -p "  Select (e.g. '1 3 a' or 'a'): " -a choices

  for c in "${choices[@]}"; do
    case "$c" in
      1) system_update ;;
      2) install_base_packages ;;
      3) install_configs ;;
      4) setup_git_ssh ;;
      a|A) install_all ;;
      q|Q) echo ""; echo "  Done."; exit 0 ;;
      *) warn "Unknown: $c" ;;
    esac
  done
done
