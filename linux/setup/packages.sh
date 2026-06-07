#!/bin/bash
# Install base Arch Linux packages
# Usage: bash packages.sh

set -euo pipefail

echo "=== Installing base packages ==="

# Core tools
sudo pacman -S --noconfirm --needed \
  base-devel git stow curl wget \
  zsh kitty rofi dunst feh \
  brightnessctl redshift xclip \
  pulseaudio pavucontrol \
  noto-fonts noto-fonts-emoji ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-fira-code

# DDC/CI brightness control for desktop monitors
sudo pacman -S --noconfirm --needed ddcutil python 2>/dev/null || true

# Development
sudo pacman -S --noconfirm --needed \
  neovim python python-pip python-virtualenvwrapper \
  nodejs npm \
  distrobox \
  xdotool wmctrl xprintidle zenity jq

# AUR packages (requires yay)
if command -v yay &>/dev/null; then
  yay -S --noconfirm --needed \
    visual-studio-code-bin \
    rustdesk-bin anydesk-bin
fi

echo "=== Base packages installed ==="
