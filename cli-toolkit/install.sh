#!/bin/sh
# smartDots CLI Toolkit Installer — POSIX-compatible
# Installs: registry.txt + smartdots.sh → ~/.smartdots/
# Adds source line to shell config (zsh/bash/sh)
# Usage:
#   curl -sL https://raw.githubusercontent.com/AmarjithTK/smartDots/main3/cli-toolkit/install.sh | sh
#   # or: sh install.sh

set -e

REPO="https://github.com/AmarjithTK/smartDots.git"
BRANCH="main3"
SOURCE_DIR="$HOME/.smartdots"
SMARTDOTS_FILE="smartdots.sh"
REGISTRY_FILE="registry.txt"

# ─── Colors ─────────────────────────────────────────────────────
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    CYAN='\033[0;36m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    GREEN='' CYAN='' YELLOW='' NC=''
fi

echo "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo "${CYAN}║     smartDots CLI Toolkit — Installer           ║${NC}"
echo "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Step 1: Check dependencies ────────────────────────────────
if ! command -v git >/dev/null 2>&1; then
    echo "git is required but not installed."
    exit 1
fi

# ─── Step 2: Clone or update ───────────────────────────────────
if [ -d "$SOURCE_DIR/.git" ]; then
    echo "${YELLOW}📂 smartDots already installed. Updating...${NC}"
    cd "$SOURCE_DIR" && git pull origin "$BRANCH" 2>/dev/null || true
else
    echo "${CYAN}📦 Cloning smartDots CLI Toolkit...${NC}"
    git clone -b "$BRANCH" --single-branch --depth 1 "$REPO" "$SOURCE_DIR" 2>/dev/null || {
        echo "Clone failed. Trying fallback..."
        git clone -b "$BRANCH" --single-branch --depth 1 \
            "https://github.com/AmarjithTK/smartDots.git" "$SOURCE_DIR"
    }
fi

# ─── Step 3: Verify files exist ─────────────────────────────────
if [ ! -f "$SOURCE_DIR/cli-toolkit/$SMARTDOTS_FILE" ]; then
    echo "Error: smartdots.sh not found in cloned repo."
    exit 1
fi

# ─── Step 4: Detect shell config file ──────────────────────────
SHELL_CONFIG=""
SHELL_NAME=""

# Check which shell the user is actually running
CURRENT_SHELL=$(basename "$SHELL" 2>/dev/null || echo "sh")

case "$CURRENT_SHELL" in
    zsh)
        SHELL_CONFIG="$HOME/.zshrc"
        SHELL_NAME="ZSH"
        ;;
    bash)
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
        SHELL_NAME="Bash"
        ;;
    *)
        # Fallback: try .profile (works for sh, dash, etc.)
        if [ -f "$HOME/.profile" ]; then
            SHELL_CONFIG="$HOME/.profile"
            SHELL_NAME="POSIX sh"
        fi
        ;;
esac

if [ -z "$SHELL_CONFIG" ]; then
    echo "${YELLOW}⚠️  Could not detect shell config file.${NC}"
    echo "   Manually add this line to your shell config:"
    echo "     . \"\$HOME/.smartdots/cli-toolkit/smartdots.sh\""
    echo ""
    echo "${GREEN}✅ smartDots files installed at ~/.smartdots/${NC}"
    exit 0
fi

# ─── Step 5: Add source line (idempotent) ─────────────────────
SOURCE_LINE=". \"\$HOME/.smartdots/cli-toolkit/smartdots.sh\""

if grep -q "smartdots.sh" "$SHELL_CONFIG" 2>/dev/null; then
    echo "${YELLOW}ℹ️  smartDots already sourced in $SHELL_CONFIG${NC}"
else
    echo "" >> "$SHELL_CONFIG"
    echo "# smartDots CLI Toolkit" >> "$SHELL_CONFIG"
    echo "$SOURCE_LINE" >> "$SHELL_CONFIG"
    echo "${GREEN}✅ Added source line to $SHELL_CONFIG${NC}"
fi

# ─── Step 6: Source immediately (if possible) ──────────────────
if [ -f "$SOURCE_DIR/cli-toolkit/$SMARTDOTS_FILE" ]; then
    . "$SOURCE_DIR/cli-toolkit/$SMARTDOTS_FILE" 2>/dev/null || true
fi

# ─── Done ───────────────────────────────────────────────────────
echo ""
echo "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo "${GREEN}║          ✅ Installation Complete!              ║${NC}"
echo "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "  ${CYAN}Try these commands:${NC}"
echo ""
echo "    ${YELLOW}helper${NC}            List all aliases"
echo "    ${YELLOW}helper flutter${NC}    Show Flutter aliases"
echo "    ${YELLOW}helper git${NC}        Show Git aliases"
echo "    ${YELLOW}helper build${NC}      Search for 'build'"
echo ""
echo "  ${CYAN}Examples:${NC}"
echo "    ${YELLOW}gs${NC}       → git status"
echo "    ${YELLOW}gcap${NC}     → git add . + commit + push"
echo "    ${YELLOW}frc${NC}      → flutter run -d chrome"
echo "    ${YELLOW}nd${NC}       → npm run dev"
echo ""
echo "  ${CYAN}Uninstall:${NC}"
echo "    rm -rf ~/.smartdots/"
echo "    # Then remove the 'smartdots.sh' line from $SHELL_CONFIG"
echo ""
