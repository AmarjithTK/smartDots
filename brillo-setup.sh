#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  brillo-setup — Brillo KDE Display Brightness Widget Installer
#  ═══════════════════════════════════════════════════════════════════
#  Installs the Brillo plasmoid for KDE Plasma:
#    - Detects if Plasma is running
#    - Installs plasmoid files to ~/.local/share/plasma/plasmoids/
#    - Adds Brillo to the KDE panel
#    - Sets up ddcutil (i2c permissions, kernel module)
#    - Creates restore-brightness autostart entry
#    - Restarts Plasma shell
#
#  USAGE:
#    bash brillo-setup.sh              # Run interactively
#    bash brillo-setup.sh --yes        # Run non-interactively
#    bash brillo-setup.sh --help       # Show help
#  ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m'
B='\033[1;37m' N='\033[0m'

info()  { echo -e "  ${C}ℹ️${N}  $1"; }
ok()    { echo -e "  ${G}✅${N} $1"; }
warn()  { echo -e "  ${Y}⚠️${N}  $1"; }
fail()  { echo -e "  ${R}❌${N} $1"; }

prompt_yes() {
  local d="${2:-y}"
  read -p "  ${1} [${d}]: " r; r="${r:-$d}"
  [[ "$r" == "y" || "$r" == "Y" || "$r" == "yes" ]]
}

PLASMOID_ID="org.amarjithtk.brillo"
PLASMOID_DST="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"

# ═══════════════════════════════════════════════════════════════════
#  EMBEDDED FILES (written via heredocs)
#  ═══════════════════════════════════════════════════════════════════

write_metadata_json() {
  local dst="$1"
  cat > "$dst/metadata.json" <<'JSONEOF'
{
    "KPlugin": {
        "Authors": [
            {
                "Email": "",
                "Name": "AmarjithTK"
            }
        ],
        "Category": "Hardware",
        "Description": "Brightness slider for desktop/laptop monitors via DDC/CI or backlight",
        "EnabledByDefault": true,
        "Icon": "brightnesssettings",
        "Id": "org.amarjithtk.brillo",
        "License": "MIT",
        "Name": "Brillo — Display Brightness",
        "ServiceTypes": [
            "Plasma/Applet"
        ],
        "Version": "1.0",
        "Website": ""
    },
    "X-Plasma-API": "declarativeappletscript",
    "X-Plasma-MainScript": "ui/main.qml",
    "X-KDE-ParentApp": "",
    "X-KDE-PluginInfo-EnabledByDefault": true
}
JSONEOF
}

write_main_qml() {
  local dst="$1"
  cat > "$dst/contents/ui/main.qml" <<'QMLEOF'
import QtQuick 2.0
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    // ─── State ────────────────────────────────────────────────
    property int currentBrightness: 50
    property int sliderValue: 50
    property string brightnessMethod: "unknown"
    property bool updatingFromCommand: false

    // ─── Layout hint: compact horizontal panel item ───────────
    Layout.minimumWidth: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
    Layout.minimumHeight: Kirigami.Units.iconSizes.smallMedium
    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2

    // ─── DataSource for running shell commands ────────────────
    PlasmaCore.DataSource {
        id: executor
        engine: "executable"
        connectedSources: []

        onNewData: {
            var stdout = data["stdout"] || ""
            var exitCode = data["exitCode"] || -1

            if (source === "brightnessGet") {
                var val = parseInt(stdout.trim())
                if (!isNaN(val) && val >= 0 && val <= 100) {
                    updatingFromCommand = true
                    currentBrightness = val
                    sliderValue = val
                    updatingFromCommand = false
                }
            } else if (source === "brightnessSet") {
                // After set, re-read actual brightness
                executor.connectSource("display-manager brightness get")
            } else if (source === "brightnessSave") {
                // After save, update display
            }

            disconnectSource(source)
        }
    }

    // ─── Timer: debounce slider changes ───────────────────────
    Timer {
        id: debounceTimer
        interval: 150
        repeat: false
        onTriggered: {
            if (!updatingFromCommand) {
                executor.connectSource("display-manager brightness set " + sliderValue)
                // Also save for persistence
                executor.connectSource("display-manager brightness save")
            }
        }
    }

    // ─── Load brightness on startup ───────────────────────────
    Component.onCompleted: {
        executor.connectSource("display-manager brightness get")
    }

    // ─── Compact representation (shown in panel) ──────────────
    PlasmaCore.IconItem {
        id: icon
        anchors.centerIn: parent
        width: Kirigami.Units.iconSizes.smallMedium
        height: width
        source: "brightnesssettings"
        active: mouseArea.containsMouse

        // Show brightness % as overlay text
        PlasmaComponents.Label {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            text: currentBrightness + "%"
            fontSizeMode: Text.Fit
            font.pixelSize: 8
            color: PlasmaCore.Theme.textColor
            opacity: 0.8
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                popup.visible = !popup.visible
            }
        }
    }

    // ─── Popup with slider ────────────────────────────────────
    PlasmaComponents.Dialog {
        id: popup
        x: 0
        y: parent.height + Kirigami.Units.smallSpacing

        width: Kirigami.Units.gridUnit * 8
        height: Kirigami.Units.gridUnit * 4

        padding: Kirigami.Units.gridUnit

        mainItem: ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            PlasmaExtras.Heading {
                level: 5
                text: "Brightness"
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                PlasmaCore.IconItem {
                    source: "brightness-low"
                    width: Kirigami.Units.iconSizes.small
                    height: width
                }

                PlasmaComponents.Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: sliderValue
                    stepSize: 1

                    onMoved: {
                        sliderValue = value
                        debounceTimer.restart()
                    }
                }

                PlasmaCore.IconItem {
                    source: "brightness-high"
                    width: Kirigami.Units.iconSizes.small
                    height: width
                }
            }

            // Percentage label
            PlasmaComponents.Label {
                text: sliderValue + "%"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                font.pixelSize: Kirigami.Units.fontSizeXLarge
                font.weight: Font.Bold
                color: PlasmaCore.Theme.textColor
            }
        }
    }
}
QMLEOF
}

# ═══════════════════════════════════════════════════════════════════
#  INSTALL FUNCTIONS
#  ═══════════════════════════════════════════════════════════════════

# ─── 1. Install plasmoid files ─────────────────────────────────
install_plasmoid() {
  echo ""
  info "Installing Brillo plasmoid files..."

  mkdir -p "$PLASMOID_DST/contents/ui"

  write_metadata_json "$PLASMOID_DST"
  write_main_qml "$PLASMOID_DST"

  ok "Plasmoid files installed → $PLASMOID_DST"
}

# ─── 2. Add to KDE panel ───────────────────────────────────────
add_to_panel() {
  echo ""
  info "Adding Brillo to KDE panel..."

  local panel_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

  if [ ! -f "$panel_config" ]; then
    warn "Panel config not found — skipping panel addition"
    return
  fi

  # Check if already present
  if grep -q "$PLASMOID_ID" "$panel_config" 2>/dev/null; then
    info "Brillo already in panel — skipping"
    return
  fi

  local panel_id=""

  # Try to detect panel containment ID via python3
  if command -v python3 &>/dev/null; then
    panel_id=$(python3 -c "
import configparser, re
c = configparser.ConfigParser()
c.read('$panel_config')
for s in c.sections():
    if s.startswith('Containements]['):
        try:
            if c.get(s, 'plugin') == 'org.kde.panel':
                print(re.search(r'Containments\]\[(\d+)\]', s).group(1))
        except:
            pass
" 2>/dev/null)
  fi

  # Fallback: grep for panel
  if [ -z "$panel_id" ]; then
    panel_id=$(grep -B5 "formfactor=2" "$panel_config" 2>/dev/null | grep -oP 'Containments\]\[\K\d+' | head -1)
  fi

  if [ -n "$panel_id" ]; then
    local applet_id
    applet_id=$(date +%s)
    if command -v kwriteconfig6 &>/dev/null; then
      kwriteconfig6 --file "$panel_config" \
        --group "Containments][$panel_id][Applets][$applet_id" \
        --key "plugin" "$PLASMOID_ID"
    else
      # Manual fallback
      echo "" >> "$panel_config"
      echo "[Containments][$panel_id][Applets][$applet_id]" >> "$panel_config"
      echo "plugin=$PLASMOID_ID" >> "$panel_config"
    fi
    ok "Brillo added to KDE panel"
  else
    warn "Could not detect KDE panel"
    info "Add Brillo manually: right-click panel → Add Widgets → Brillo"
  fi
}

# ─── 3. Setup ddcutil (I2C) ────────────────────────────────────
setup_ddcutil() {
  echo ""
  info "Setting up DDC/CI (brightness control via monitor control)..."

  # Load i2c kernel module
  if lsmod | grep -q "^i2c_dev" 2>/dev/null; then
    info "i2c-dev module already loaded"
  else
    sudo modprobe i2c-dev 2>/dev/null && ok "i2c-dev module loaded" || warn "Could not load i2c-dev"
  fi

  # Persist kernel module
  if [ ! -f /etc/modules-load.d/i2c-dev.conf ]; then
    echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null && ok "i2c-dev persistence configured"
  else
    info "i2c-dev persistence already configured"
  fi

  # Add user to i2c group
  if groups "$USER" | grep -q "\bi2c\b" 2>/dev/null; then
    info "User already in i2c group"
  else
    sudo usermod -aG i2c "$USER" && ok "User added to i2c group (log out/in to apply)"
  fi
}

# ─── 4. Create restore-brightness autostart ─────────────────────
setup_autostart() {
  echo ""
  info "Creating restore-brightness autostart..."

  local autostart_dst="$HOME/.config/autostart"
  mkdir -p "$autostart_dst"

  cat > "$autostart_dst/restore-brightness.desktop" <<'AUTOSTART'
[Desktop Entry]
Type=Application
Name=Restore Display Brightness
Exec=display-manager brightness restore
Terminal=false
X-KDE-autostart-phase=2
AUTOSTART
  ok "restore-brightness.desktop created"

  # Save current brightness if display-manager is available
  if command -v display-manager &>/dev/null; then
    display-manager brightness save 2>/dev/null && ok "Current brightness saved" || true
  else
    warn "display-manager not found in PATH — brightness save skipped"
  fi
}

# ─── 5. Restart Plasma shell ───────────────────────────────────
restart_plasma() {
  echo ""
  if [ "${1:-}" != "--yes" ]; then
    if ! prompt_yes "Restart Plasma shell now?" "y"; then
      info "Skipping Plasma restart"
      info "Restart manually: kquitapp6 plasmashell && kstart6 plasmashell"
      return
    fi
  fi

  warn "Restarting Plasma shell in 3s..."
  sleep 3

  if command -v kquitapp6 &>/dev/null; then
    kquitapp6 plasmashell 2>/dev/null || true
    sleep 2
    kstart6 plasmashell &>/dev/null &
    ok "Plasma shell restarted"
  elif command -v kquitapp5 &>/dev/null; then
    kquitapp5 plasmashell 2>/dev/null || true
    sleep 2
    kstart5 plasmashell &>/dev/null &
    ok "Plasma shell restarted"
  else
    warn "Could not restart Plasma automatically"
    info "Restart manually: kquitapp6 plasmashell && kstart6 plasmashell"
  fi
}

# ═══════════════════════════════════════════════════════════════════
#  MAIN
#  ═══════════════════════════════════════════════════════════════════

setup_brillo() {
  echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║      Brillo — Display Brightness Widget             ║"
  echo "╚══════════════════════════════════════════════════════╝"

  # Check Plasma is running
  if ! command -v plasmashell &>/dev/null; then
    fail "KDE Plasma not detected (plasmashell not found)"
    exit 1
  fi

  install_plasmoid
  add_to_panel
  setup_ddcutil
  setup_autostart
  restart_plasma "${1:-}"

  echo ""
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║      Brillo Installation Complete!                  ║"
  echo "╠══════════════════════════════════════════════════════╣"
  echo "║  If Brillo is not visible in the panel:             ║"
  echo "║    Right-click panel → Add Widgets → Brillo         ║"
  echo "╚══════════════════════════════════════════════════════╝"
}

case "${1:-}" in
  --help|-h)
    echo "Usage: bash brillo-setup.sh [--yes]"
    echo "  --yes    Run non-interactively (auto-approve all)"
    exit 0
    ;;
  *)
    setup_brillo "${1:-}"
    ;;
esac
