#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  system-setup — base packages, backlight, GRUB, configs
#  ═══════════════════════════════════════════════════════════════════
#  A simple while-loop menu for setting up Arch Linux.
#  Derived from main2 branch — basepackages, brightness, GRUB.
#
#  USAGE:
#    bash system-setup.sh
#  ═══════════════════════════════════════════════════════════════════

# ── Style ─────────────────────────────────────────────────────────
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
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
  info "This includes: git, zsh, kitty, neovim, rofi, docker, fonts, and more"

  # Refresh package databases
  sudo pacman -Syy --noconfirm

  # Core packages
  sudo pacman -S --noconfirm --needed \
    base-devel git stow curl wget \
    zsh kitty rofi dunst feh \
    brightnessctl ddcutil redshift xclip \
    neovim python python-pip \
    nodejs npm distrobox \
    docker docker-compose \
    noto-fonts ttf-jetbrains-mono ttf-jetbrains-mono-nerd \
    ttf-fira-code ttf-firacode-nerd powerline-fonts \
    github-cli neofetch htop tree \
    xdotool wmctrl xprintidle zenity jq \
    papirus-icon-theme \
    --noconfirm 2>&1 | tail -1

  # AUR helper check
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
#  2. ACPI NATIVE BACKLIGHT
#  ═══════════════════════════════════════════════════════════════════

setup_acpi_backlight() {
  echo ""
  info "Setting up ACPI native backlight..."

  # Find backlight interface
  local backlight_iface=""
  for d in /sys/class/backlight/*/; do
    if [ -d "$d" ]; then
      backlight_iface=$(basename "$d")
      break
    fi
  done

  if [ -z "$backlight_iface" ]; then
    warn "No backlight interface found at /sys/class/backlight/"
    info "Trying to load native backlight module..."
    sudo modprobe thinkpad_acpi 2>/dev/null || true
    for d in /sys/class/backlight/*/; do
      if [ -d "$d" ]; then
        backlight_iface=$(basename "$d")
        break
      fi
    done
  fi

  if [ -z "$backlight_iface" ]; then
    fail "No backlight interface available"
    info "Try: ddcutil (external monitors) or install brightnessctl"
    return 1
  fi

  ok "Backlight interface: $backlight_iface"

  # Add user to video group for backlight access
  if groups "$USER" | grep -q '\bvideo\b' 2>/dev/null; then
    info "User already in video group"
  else
    sudo usermod -aG video "$USER"
    ok "Added user to video group (log out/in to apply)"
  fi

  # Create udev rule for backlight permissions
  local udev_file="/etc/udev/rules.d/90-backlight.rules"
  if [ ! -f "$udev_file" ]; then
    echo "ACTION==\"add\", SUBSYSTEM==\"backlight\", RUN+=\"/bin/chmod 666 /sys/class/backlight/%k/brightness /sys/class/backlight/%k/bl_power\"" | \
      sudo tee "$udev_file" >/dev/null
    ok "Udev rule created for backlight access"
  else
    info "Udev rule already exists"
  fi

  # Create brightness control script
  local bindir="$HOME/.local/bin"
  mkdir -p "$bindir"

  cat > "$bindir/acpi-brightness" <<'BRIGHT'
#!/bin/bash
# ACPI native backlight control
# Usage: acpi-brightness [get|set N|up|down]

IFACE=""
for d in /sys/class/backlight/*/; do
  [ -d "$d" ] && IFACE=$(basename "$d") && break
done

[ -z "$IFACE" ] && echo "No backlight interface" && exit 1

SYSFS="/sys/class/backlight/$IFACE"
MAX=$(cat "$SYSFS/max_brightness")
CUR=$(cat "$SYSFS/brightness")

case "${1:-get}" in
  get)
    PERCENT=$(( CUR * 100 / MAX ))
    echo "$PERCENT"
    ;;
  set)
    [ -z "$2" ] && echo "Usage: acpi-brightness set <percent>" && exit 1
    VAL=$(( $2 * MAX / 100 ))
    [ "$VAL" -lt 0 ] && VAL=0
    [ "$VAL" -gt "$MAX" ] && VAL="$MAX"
    echo "$VAL" | sudo tee "$SYSFS/brightness" >/dev/null
    ;;
  up)
    NEW=$(( CUR + (MAX / 20) ))
    [ "$NEW" -gt "$MAX" ] && NEW="$MAX"
    echo "$NEW" | sudo tee "$SYSFS/brightness" >/dev/null
    ;;
  down)
    NEW=$(( CUR - (MAX / 20) ))
    [ "$NEW" -lt 0 ] && NEW=0
    echo "$NEW" | sudo tee "$SYSFS/brightness" >/dev/null
    ;;
  *)
    echo "Usage: acpi-brightness [get|set N|up|down]"
    ;;
esac
BRIGHT
  chmod +x "$bindir/acpi-brightness"
  ok "Created ~/.local/bin/acpi-brightness"

  # Save current brightness
  local saved_file="$HOME/.aliasmanager/brightness-saved"
  "$bindir/acpi-brightness" get > "$saved_file" 2>/dev/null || true
  ok "Current brightness saved"

  # Restore brightness on shell start via aliasmanager hook
  local hook_file="$HOME/.aliasmanager/brightness-hook.sh"
  cat > "$hook_file" <<'HOOK'
# Restore saved brightness on shell start
SAVED="$HOME/.aliasmanager/brightness-saved"
if [ -f "$SAVED" ]; then
  VAL=$(cat "$SAVED")
  [ -n "$VAL" ] && [ "$VAL" -gt 0 ] && acpi-brightness set "$VAL" 2>/dev/null || true
fi
HOOK

  # Check if aliasmanager dir exists and add hook
  local rcfile="$HOME/.zshrc"
  if [ -f "$rcfile" ] && ! grep -q "brightness-hook" "$rcfile" 2>/dev/null; then
    echo "" >> "$rcfile"
    echo "# Restore ACPI backlight on shell start" >> "$rcfile"
    echo "[ -f \"$hook_file\" ] && . \"$hook_file\"" >> "$rcfile"
  fi

  ok "ACPI backlight setup complete"
  state_mark "acpi_backlight"
}

# ═══════════════════════════════════════════════════════════════════
#  3. GRUB CONFIGURATION
#  ═══════════════════════════════════════════════════════════════════

setup_grub() {
  echo ""
  info "Configuring GRUB..."

  # Check if GRUB is installed
  if [ ! -f /etc/default/grub ]; then
    warn "GRUB not found at /etc/default/grub"
    if command -v grub-install &>/dev/null; then
      info "GRUB is installed but config may be elsewhere"
    else
      fail "GRUB is not installed"
      info "Install: sudo pacman -S grub"
      return 1
    fi
  fi

  # Backup current GRUB config
  local bak="/etc/default/grub.bak.$(date +%Y%m%d-%H%M%S)"
  sudo cp /etc/default/grub "$bak"
  ok "Backed up GRUB config → $bak"

  # Security: set GRUB password if not set
  local grub_password_set=false
  if grep -q "GRUB_PASSWORD" /etc/default/grub 2>/dev/null; then
    info "GRUB password already set"
    grub_password_set=true
  fi

  # Apply GRUB tweaks
  sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nowatchdog acpi_backlight=native"/' /etc/default/grub
  sudo sed -i 's/#GRUB_DISABLE_RECOVERY/GRUB_DISABLE_RECOVERY/' /etc/default/grub
  sudo sed -i 's/#GRUB_TIMEOUT_STYLE=menu/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
  sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub

  ok "GRUB config updated (acpi_backlight=native, timeout=3)"

  # Install GRUB theme (Nord)
  local theme_dst="/boot/grub/themes/nord"
  if [ ! -d "$theme_dst" ]; then
    info "Installing GRUB theme..."
    sudo mkdir -p "$theme_dst"

    # Create a minimal Nord GRUB theme
    sudo tee "$theme_dst/theme.txt" >/dev/null <<'THEME'
# Nord GRUB Theme
title-text: ""
title-color: "#ECEFF4"
title-font: "DejaVu Sans Bold 18"
desktop-image: ""
desktop-color: "#2E3440"

+ boot_menu {
    left = 25%
    top = 30%
    width = 50%
    height = 60%
    item_color = "#D8DEE9"
    selected_item_color = "#88C0D0"
    item_height = 32
    item_spacing = 8
    item_padding = 4
    item_font = "DejaVu Sans 14"
    selected_item_font = "DejaVu Sans Bold 14"
    selected_item_pixmap_style = "select_*.png"
    scrollbar = false
}

+ progress_bar {
    id = "__timeout__"
    left = 25%
    top = 92%
    width = 50%
    height = 6
    fg_color = "#88C0D0"
    bg_color = "#4C566A"
}
THEME
    echo "GRUB_THEME=\"$theme_dst/theme.txt\"" | sudo tee -a /etc/default/grub >/dev/null
    ok "Nord GRUB theme installed"
  else
    info "GRUB theme already installed"
  fi

  # Regenerate GRUB config
  info "Regenerating GRUB config..."
  if command -v grub-mkconfig &>/dev/null; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | tail -1
    ok "GRUB config regenerated"
  else
    warn "grub-mkconfig not found — regenerate manually"
  fi

  ok "GRUB setup complete"
  state_mark "grub"
}

# ═══════════════════════════════════════════════════════════════════
#  4. INSTALL CONFIG FILES (stow)
#  ═══════════════════════════════════════════════════════════════════

install_configs() {
  echo ""
  info "Installing config files..."

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Copy .gitconfig and .gitignore_global
  for f in .gitconfig .gitignore_global; do
    if [ -f "$script_dir/$f" ]; then
      cp -n "$script_dir/$f" "$HOME/" 2>/dev/null && ok "Copied $f to ~/" || info "$f already exists — skipped"
    fi
  done

  # Git default branch
  git config --global init.defaultBranch main 2>/dev/null || true

  ok "Config files installed"
  state_mark "configs"
}

# ═══════════════════════════════════════════════════════════════════
#  5. GIT SSH KEY SETUP
#  ═══════════════════════════════════════════════════════════════════

setup_git_ssh() {
  echo ""
  info "Setting up Git + SSH..."

  # Git user config
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

  # SSH key
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

  # Show public key
  if [ -f "$keyfile.pub" ]; then
    echo ""
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │  YOUR SSH PUBLIC KEY                                │"
    echo "  │  Add to GitHub: https://github.com/settings/keys    │"
    echo "  ├─────────────────────────────────────────────────────┤"
    cat "$keyfile.pub" | sed 's/^/  │  /'
    echo "  └─────────────────────────────────────────────────────┘"
    echo ""

    # Test connection
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
      ok "SSH key authenticated with GitHub"
    else
      warn "SSH key not added to GitHub yet"
    fi

    # Copy to clipboard if available
    if command -v xclip &>/dev/null; then
      xclip -selection clipboard < "$keyfile.pub"
      ok "Public key copied to clipboard"
    fi
  fi

  state_mark "git_ssh"
}

# ═══════════════════════════════════════════════════════════════════
#  6. LAPTOP POWER MANAGEMENT (TLP)
#  ═══════════════════════════════════════════════════════════════════

setup_laptop_power() {
  echo ""
  info "Setting up laptop power management (TLP)..."

  sudo pacman -Syy --noconfirm
  sudo pacman -S --noconfirm tlp tlp-rdw 2>&1 | tail -1
  sudo systemctl enable tlp.service 2>/dev/null
  sudo systemctl enable NetworkManager-dispatcher.service 2>/dev/null
  sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket 2>/dev/null

  ok "TLP enabled — battery life optimized"
  state_mark "laptop_power"
}

# ═══════════════════════════════════════════════════════════════════
#  7. SYSTEM UPDATE
#  ═══════════════════════════════════════════════════════════════════

system_update() {
  echo ""
  info "Updating system..."
  sudo pacman -Syu --noconfirm 2>&1 | tail -3
  ok "System updated"
  state_mark "system_updated"
}

# ═══════════════════════════════════════════════════════════════════
#  8. INSTALL EVERYTHING
#  ═══════════════════════════════════════════════════════════════════

install_all() {
  echo ""
  echo "  ┌─────────────────────────────────────────────────────┐"
  echo "  │  Installing EVERYTHING                              │"
  echo "  └─────────────────────────────────────────────────────┘"
  install_base_packages
  setup_acpi_backlight
  setup_grub
  setup_git_ssh
  install_configs
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
  printf "  │  %s2%s) ACPI backlight       [%s]                   │\n" "$BOLD" "$RESET" "$(check acpi_backlight)"
  printf "  │  %s3%s) GRUB configuration   [%s]                   │\n" "$BOLD" "$RESET" "$(check grub)"
  printf "  │  %s4%s) Config files         [%s]                   │\n" "$BOLD" "$RESET" "$(check configs)"
  printf "  │  %s5%s) Git + SSH key        [%s]                   │\n" "$BOLD" "$RESET" "$(check git_ssh)"
  printf "  │  %s6%s) Laptop power (TLP)   [%s]                   │\n" "$BOLD" "$RESET" "$(check laptop_power)"
  printf "  │  %s7%s) System update        [%s]                   │\n" "$BOLD" "$RESET" "$(check system_updated)"
  echo "  │                                              │"
  echo "  │  a) Install ALL                              │"
  echo "  │  q) Quit                                     │"
  echo "  └─────────────────────────────────────────────────────┘"
  echo ""
  read -p "  Select (e.g. '1 3 5' or 'a'): " -a choices

  for c in "${choices[@]}"; do
    case "$c" in
      1) install_base_packages ;;
      2) setup_acpi_backlight ;;
      3) setup_grub ;;
      4) install_configs ;;
      5) setup_git_ssh ;;
      6) setup_laptop_power ;;
      7) system_update ;;
      a|A) install_all ;;
      q|Q) echo ""; echo "  Done."; exit 0 ;;
      *) warn "Unknown: $c" ;;
    esac
  done
done
