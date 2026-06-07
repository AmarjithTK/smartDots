#!/bin/bash
# Firefox theme setup — symlink centralized userChrome.css to all profiles
# Usage: bash firefox.sh

set -euo pipefail

echo "=== Firefox Theme Setup ==="

# Install Firefox if missing
if ! command -v firefox &>/dev/null; then
  echo "Installing Firefox..."
  sudo pacman -S firefox --noconfirm
fi

USERCHROME="$HOME/.config/firefox/userChrome.css"

if [[ ! -f "$USERCHROME" ]]; then
  echo "userChrome.css not found at $USERCHROME"
  exit 1
fi

# Link to all Firefox profiles
while IFS= read -r profile; do
  chrome_dir="$profile/chrome"
  mkdir -p "$chrome_dir"
  ln -sf "$USERCHROME" "$chrome_dir/userChrome.css"
  echo "Linked: $chrome_dir/userChrome.css"
done < <(find "$HOME/.mozilla/firefox/" -maxdepth 1 -name "*.default*" -type d 2>/dev/null)

echo "=== Firefox theme setup complete ==="
