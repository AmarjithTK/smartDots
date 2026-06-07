#!/bin/bash
# smartDots SSH-First Cross-Platform Installer
# Detects OS → SSH clone (with auto keygen) → bootstrap
# Usage: bash <(curl -sL https://is.gd/smartdots)
#    or: curl -sL https://raw.githubusercontent.com/AmarjithTK/smartDots/main3/install.sh | bash

set -euo pipefail

REPO="git@github.com:AmarjithTK/smartDots.git"
REPO_HTTPS="https://github.com/AmarjithTK/smartDots.git"
BRANCH="main3"
DEST="$HOME/smartDots"

# ─── Utilities ───────────────────────────────────────────────────────

box_print() {
  local text="$1"
  local len="${#text}"
  local top="╔$(printf '═%.0s' $(seq 1 $((len + 2))))╗"
  local mid="║ $text ║"
  local bot="╚$(printf '═%.0s' $(seq 1 $((len + 2))))╝"
  echo ""
  echo "$top"
  echo "$mid"
  echo "$bot"
  echo ""
}

pretty_print_key() {
  local key_file="$1"
  local key_content
  key_content=$(cat "$key_file")

  # Split key into parts for wrapping
  local key_type
  key_type=$(echo "$key_content" | awk '{print $1}')
  local key_data
  key_data=$(echo "$key_content" | awk '{print $2}')
  local key_comment
  key_comment=$(echo "$key_content" | awk '{print $3}')

  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════╗"
  echo "║                     YOUR SSH PUBLIC KEY                             ║"
  echo "╠══════════════════════════════════════════════════════════════════════╣"
  echo "║                                                                      ║"
  echo "║  $key_type $key_data  ║"
  echo "║  $key_comment"
  echo "║                                                                      ║"
  echo "╚══════════════════════════════════════════════════════════════════════╝"
  echo ""
}

clickable_url() {
  # OSC 8 hyperlink — works in Kitty, Konsole, iTerm2, VSCode terminal, etc.
  echo -e "\e]8;;$1\e\\\\$2\e]8;;\e\\\\"
}

detect_ssh_key() {
  for f in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/id_ecdsa.pub"; do
    if [[ -f "$f" ]]; then
      echo "$f"
      return 0
    fi
  done
  return 1
}

generate_ssh_key() {
  local key_file="$HOME/.ssh/id_ed25519"
  local email="${USER:-user}@$(hostname 2>/dev/null || echo 'localhost')"

  echo ""
  echo "🔑 No SSH key found. Generating ed25519 key pair..."
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$email" -f "$key_file" -N "" 2>/dev/null
  echo "✅ SSH key generated: $key_file.pub"
  echo "$key_file.pub"
}

test_ssh_connection() {
  ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
}

upload_via_gh() {
  local key_file="$1"
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
      echo "☁️  Uploading SSH key to GitHub via gh CLI..."
      gh ssh-key add "$key_file" --title "smartdots-$(hostname 2>/dev/null || echo 'unknown')-$(date +%Y%m%d)"
      echo "✅ SSH key uploaded to GitHub!"
      return 0
    else
      echo "⚠️  gh CLI found but not authenticated. Run 'gh auth login' first."
    fi
  else
    echo "ℹ️  gh CLI not installed. Install with: sudo pacman -S github-cli"
  fi
  return 1
}

clone_via_ssh() {
  echo "🔗 Cloning via SSH: $REPO (branch: $BRANCH)"
  git clone -b "$BRANCH" --single-branch --depth 1 "$REPO" "$DEST" 2>/dev/null
}

clone_via_https() {
  echo "🔗 Cloning via HTTPS: $REPO_HTTPS (branch: $BRANCH)"
  git clone -b "$BRANCH" --single-branch --depth 1 "$REPO_HTTPS" "$DEST"
}

show_github_instructions() {
  local key_file="$1"
  local ghrl="https://github.com/settings/ssh/new"

  echo ""
  echo "╔══════════════════════════════════════════════════════════════════════╗"
  echo "║             ADD YOUR SSH KEY TO GITHUB — 3 WAYS                     ║"
  echo "╠══════════════════════════════════════════════════════════════════════╣"
  echo "║                                                                      ║"
  echo "║  🔹 WAY 1 — gh CLI (easiest):                                      ║"
  echo "║     gh auth login                                                   ║"
  echo "║     gh ssh-key add $key_file --title \"$(hostname)\"                    ║"
  echo "║                                                                      ║"
  echo "║  🔹 WAY 2 — Browser (manual):                                      ║"
  echo "║     Open: $(clickable_url "$ghrl" "$ghrl")"
  echo "║     Click \"New SSH Key\" → paste the key above → Add                ║"
  echo "║                                                                      ║"
  echo "║  🔹 WAY 3 — Copy & paste this command:                             ║"
  echo "║     cat $key_file                                                   ║"
  echo "║     # Then manually add at: $ghrl           ║"
  echo "║                                                                      ║"
  echo "╚══════════════════════════════════════════════════════════════════════╝"
  echo ""
}

run_bootstrap() {
  echo ""
  echo "🚀 Running smartDots bootstrap..."
  cd "$DEST"
  bash linux/setup/bootstrap.sh

  # Offer CLI Toolkit install after bootstrap
  echo ""
  echo "🛠️  Install CLI Toolkit (60 aliases + helper command)?"
  read -p "   This adds 'helper', 'gs', 'fpg', 'nd' etc. [Y/n]: " install_tk
  install_tk="${install_tk:-y}"
  if [ "$install_tk" = "y" ] || [ "$install_tk" = "Y" ]; then
    echo ""
    sh "$DEST/cli-toolkit/install.sh"
  fi
}

install_cli_toolkit() {
  echo ""
  echo "🚀 Installing CLI Toolkit (aliases + helper)..."
  cd "$DEST"
  sh cli-toolkit/install.sh
}

# ─── Platform Detection ───────────────────────────────────────────────

OS="$(uname -s)"
case "$OS" in
  Linux) ;;
  Darwin)
    echo "macOS detected — Linux scripts may not work directly."
    echo "Clone manually: git clone -b $BRANCH $REPO"
    exit 1
    ;;
  *)
    echo ""
    echo "=== smartDots Windows Install ==="
    echo ""
    echo "Windows users, run this in PowerShell:"
    echo ""
    echo "  git clone -b $BRANCH $REPO_HTTPS \$env:USERPROFILE\\smartDots"
    echo "  cd \$env:USERPROFILE\\smartDots\\windows"
    echo "  powershell -ExecutionPolicy Bypass -File install.ps1"
    echo ""
    echo "Or use the standalone install:"
    echo "  powershell -ExecutionPolicy Bypass -File windows/install.ps1"
    echo ""
    exit 0
    ;;
esac

# ═══════════════════════════════════════════════════════════════════════
#  LINUX INSTALL — SSH-First
# ═══════════════════════════════════════════════════════════════════════

echo ""
box_print "smartDots — SSH-First Installer"
echo "Target: $DEST"
echo ""

# ─── Already installed? ───────────────────────────────────────────────
if [[ -d "$DEST/.git" ]]; then
  echo "📂 smartDots already cloned. Pulling updates..."
  cd "$DEST"
  git pull origin "$BRANCH"
  run_bootstrap
  exit 0
fi

# ─── Try SSH first ────────────────────────────────────────────────────
if clone_via_ssh; then
  echo "✅ Cloned successfully via SSH!"
  run_bootstrap
  exit 0
fi

# ─── SSH failed — diagnose ────────────────────────────────────────────
echo ""
echo "⚠️  SSH clone failed. Diagnosing..."

# Check internet
if ! ping -c 1 github.com &>/dev/null; then
  echo "❌ Cannot reach github.com. Check your internet connection."
  exit 1
fi

SSH_KEY=$(detect_ssh_key || true)

if [[ -z "$SSH_KEY" ]]; then
  # ─── No SSH key → offer to generate ─────────────────────────────────
  echo ""
  echo "🔍 No SSH key found."
  echo ""
  echo "Choose:"
  echo "  1) Generate a new SSH key + add to GitHub (recommended)"
  echo "  2) Use HTTPS instead (no key needed)"
  echo "  3) Quit"
  echo ""
  read -p "Choice [1]: " choice
  choice="${choice:-1}"

  case "$choice" in
    2)
      echo ""
      clone_via_https
      run_bootstrap
      exit 0
      ;;
    3)
      echo "Exiting."
      exit 1
      ;;
    *)
      SSH_KEY=$(generate_ssh_key)
      ;;
  esac
else
  echo "✅ SSH key found: $SSH_KEY"
fi

# ─── Pretty-print the key ─────────────────────────────────────────────
echo ""
pretty_print_key "$SSH_KEY"

# ─── Test existing SSH connection ─────────────────────────────────────
if test_ssh_connection; then
  echo "✅ SSH key already added to GitHub! Retrying clone..."
  if clone_via_ssh; then
    run_bootstrap
    exit 0
  fi
fi

# ─── Try gh CLI upload ────────────────────────────────────────────────
echo ""
echo "☁️  Attempting to upload SSH key to GitHub..."
if upload_via_gh "$SSH_KEY"; then
  echo ""
  echo "⏳ Waiting 5s for GitHub to register the key..."
  sleep 5
  if clone_via_ssh; then
    run_bootstrap
    exit 0
  fi
fi

# ─── Show manual instructions ─────────────────────────────────────────
show_github_instructions "$SSH_KEY"

echo ""
echo "After adding the key to GitHub, the script will retry."
read -p "Press ENTER when done (or type 'https' to use HTTPS, 'q' to quit): " input

if [[ "$input" == "https" ]]; then
  clone_via_https
  run_bootstrap
  exit 0
elif [[ "$input" == "q" ]]; then
  echo "Exiting."
  exit 1
fi

# Retry SSH clone
if clone_via_ssh; then
  echo "✅ Cloned successfully!"
  run_bootstrap
else
  echo ""
  echo "❌ SSH still failing. Falling back to HTTPS..."
  clone_via_https
  run_bootstrap
fi
