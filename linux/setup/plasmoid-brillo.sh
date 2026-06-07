#!/bin/bash
# Brillo KDE Plasmoid — fully automated setup
# Installs the plasmoid, adds to KDE panel, sets up DDC/CI permissions
# Usage: bash plasmoid-brillo.sh
#
# What this script does:
#   1. Installs Plasmoid files to ~/.local/share/plasma/plasmoids/
#   2. Adds the Brillo widget to your KDE panel
#   3. Installs display-manager to ~/.local/bin/
#   4. Sets up brightness restore on login (KDE autostart)
#   5. Installs ddcutil and configures permissions (if needed)
#   6. Restarts Plasma shell to apply changes

set -euo pipefail

SMARTDOTS_DIR="${SMARTDOTS_DIR:-$HOME/smartDots}"
PLASMOID_ID="org.amarjithtk.brillo"
PLASMOID_SRC="$SMARTDOTS_DIR/linux/stow/plasmoids/$PLASMOID_ID"
PLASMOID_DST="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"
BIN_SRC="$SMARTDOTS_DIR/linux/bin/display-manager"
BIN_DST="$HOME/.local/bin/display-manager"
STATE_DIR="$HOME/.helpers"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Brillo — KDE Brightness Plasmoid Auto-Installer     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ─── Step 1: Install Plasmoid files ───────────────────────────
echo "📦 [1/6] Installing Brillo plasmoid..."
mkdir -p "$PLASMOID_DST/contents/ui"
cp -r "$PLASMOID_SRC/metadata.json" "$PLASMOID_DST/"
cp -r "$PLASMOID_SRC/contents/ui/main.qml" "$PLASMOID_DST/contents/ui/"
echo "  ✅ Plasmoid installed: $PLASMOID_DST"

# ─── Step 2: Install display-manager binary ───────────────────
echo "📦 [2/6] Installing display-manager script..."
mkdir -p "$HOME/.local/bin"
cp "$BIN_SRC" "$BIN_DST"
chmod +x "$BIN_DST"
echo "  ✅ Script installed: $BIN_DST"

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "⚠️  Adding ~/.local/bin to PATH in ~/.zshconfig..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshconfig"
    export PATH="$HOME/.local/bin:$PATH"
fi

# ─── Step 3: Add Brillo to KDE Panel ──────────────────────────
echo "📦 [3/6] Adding Brillo widget to KDE panel..."

PANEL_CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

# Find the panel containment ID (formfactor=2 for horizontal panel)
find_panel_id() {
    python3 -c "
import configparser
config = configparser.ConfigParser()
config.read('$PANEL_CONFIG')
for section in config.sections():
    if section.startswith('Containments]['):
        try:
            if config.get(section, 'plugin') == 'org.kde.panel':
                # Extract containment ID
                import re
                m = re.search(r'Containments\]\[(\d+)\]', section)
                if m:
                    print(m.group(1))
                    return
        except:
            pass
" 2>/dev/null
}

PANEL_ID=$(find_panel_id)

if [[ -z "$PANEL_ID" ]]; then
    echo "  ⚠️  Could not find panel ID. Trying alternative detection..."
    # Try harder: look for formfactor=2 sections
    PANEL_ID=$(grep -B5 "formfactor=2" "$PANEL_CONFIG" 2>/dev/null | grep "^\[Containments" | head -1 | grep -oP '\d+')
fi

if [[ -n "$PANEL_ID" ]]; then
    echo "  📍 Found panel ID: $PANEL_ID"

    # Generate unique applet ID (timestamp-based to avoid collision)
    APPLET_ID=$(date +%s)

    # Check if already installed
    if grep -q "$PLASMOID_ID" "$PANEL_CONFIG" 2>/dev/null; then
        echo "  ℹ️  Brillo already in panel config. Skipping."
    else
        # Use kwriteconfig6 or kwriteconfig5 to add the applet
        if command -v kwriteconfig6 &>/dev/null; then
            kwriteconfig6 --file "$PANEL_CONFIG" \
                --group "Containments][$PANEL_ID][Applets][$APPLET_ID" \
                --key "plugin" "$PLASMOID_ID"
            echo "  ✅ Brillo added to panel (applet ID: $APPLET_ID)"
        elif command -v kwriteconfig5 &>/dev/null; then
            kwriteconfig5 --file "$PANEL_CONFIG" \
                --group "Containments][$PANEL_ID][Applets][$APPLET_ID" \
                --key "plugin" "$PLASMOID_ID"
            echo "  ✅ Brillo added to panel (applet ID: $APPLET_ID)"
        else
            # Manual fallback: append to config
            echo "" >> "$PANEL_CONFIG"
            echo "[Containments][$PANEL_ID][Applets][$APPLET_ID]" >> "$PANEL_CONFIG"
            echo "plugin=$PLASMOID_ID" >> "$PANEL_CONFIG"
            echo "  ✅ Brillo added to panel manually (applet ID: $APPLET_ID)"
        fi
    fi
else
    echo "  ⚠️  Could not detect panel. You can add Brillo manually:"
    echo "     Right-click panel → Add Widgets → Brillo → Display Brightness"
fi

# ─── Step 4: Set up brightness persistence ────────────────────
echo "📦 [4/6] Setting up brightness persistence..."
mkdir -p "$STATE_DIR"

# Save current brightness for restore on login
if command -v display-manager &>/dev/null; then
    display-manager brightness save 2>/dev/null || true
fi

# Add autostart restore via .desktop file
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cp "$SMARTDOTS_DIR/linux/stow/plasma-autostart/restore-brightness.desktop" "$AUTOSTART_DIR/"
echo "  ✅ Brightness auto-restore configured"

# ─── Step 5: Install ddcutil + permissions (if needed) ────────
echo "📦 [5/6] Checking DDC/CI support..."

# Check if this is likely a desktop (no backlight)
if ! brightnessctl -l 2>/dev/null | grep -q .; then
    if ! command -v ddcutil &>/dev/null; then
        echo "  🔧 Desktop detected — installing ddcutil..."
        sudo pacman -S --noconfirm ddcutil 2>/dev/null || {
            echo "  ⚠️  Could not install ddcutil. Install manually: sudo pacman -S ddcutil"
        }
    else
        echo "  ✅ ddcutil already installed"
    fi

    # Load i2c-dev module
    if ! lsmod | grep -q i2c_dev; then
        echo "  🔧 Loading i2c-dev kernel module..."
        sudo modprobe i2c-dev || true
    fi

    # Persist i2c-dev
    if [[ ! -f /etc/modules-load.d/i2c-dev.conf ]]; then
        echo "  🔧 Persisting i2c-dev module..."
        echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null || true
    fi

    # Add user to i2c group
    if ! groups "$USER" | grep -q i2c; then
        echo "  🔧 Adding $USER to i2c group..."
        sudo usermod -aG i2c "$USER" 2>/dev/null || true
        echo "  ⚠️  You need to log out and back in for i2c group to take effect."
    fi

    # Test ddcutil
    if command -v ddcutil &>/dev/null; then
        if ddcutil detect 2>/dev/null | grep -q "Monitor"; then
            echo "  ✅ DDC/CI monitor detected! Brightness control ready."
        else
            echo "  ⚠️  ddcutil installed but no DDC/CI monitor detected."
            echo "     Make sure your monitor supports DDC/CI and it's enabled in OSD settings."
        fi
    fi
else
    echo "  ℹ️  Laptop backlight detected — using built-in brightness control."
fi

# ─── Step 6: Restart Plasma Shell ─────────────────────────────
echo "📦 [6/6] Restarting Plasma shell to apply changes..."
echo "  🔄 Plasma shell will restart in 3 seconds..."
sleep 1
echo "  🔄 2..."
sleep 1
echo "  🔄 1..."
sleep 1

if command -v kquitapp6 &>/dev/null; then
    kquitapp6 plasmashell 2>/dev/null || true
    sleep 2
    kstart6 plasmashell &>/dev/null &
elif command -v kquitapp5 &>/dev/null; then
    kquitapp5 plasmashell 2>/dev/null || true
    sleep 2
    kstart5 plasmashell &>/dev/null &
elif command -v plasma_session &>/dev/null; then
    # KDE 4/5 fallback
    kquitapp plasma-desktop 2>/dev/null || true
    sleep 2
    plasma-desktop &>/dev/null &
else
    echo "  ⚠️  Could not restart Plasma shell automatically."
    echo "     Press Alt+F2, type 'plasmashell --replace' and press Enter."
fi

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           ✅  Brillo Setup Complete!                     ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║                                                          ║"
echo "║  • Brightness widget added to your panel                ║"
echo "║  • Auto-restore on login configured                     ║"
echo "║  • DDC/CI permissions set up (if applicable)            ║"
echo "║                                                          ║"
echo "║  If the widget didn't appear, add manually:             ║"
echo "║    Right-click panel → Add Widgets → Brillo             ║"
echo "║                                                          ║"
echo "║  Test brightness: display-manager brightness gui        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
