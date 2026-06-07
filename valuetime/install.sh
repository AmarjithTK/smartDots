#!/bin/bash

# ═══════════════════════════════════════════════════════════════════
#  YouTube Lockdown Installer for Arch Linux
#  Allowed time: 18:00 -> 21:00
#  ═══════════════════════════════════════════════════════════════════

# ---------- ADMIN CHECK ----------
if [ "$EUID" -ne 0 ]; then
  echo "Please run this installer as root (use sudo)."
  exit 1
fi

# ---------- DIRECTORY SETUP ----------
INSTALL_DIR="/opt/youtube_lockdown"
mkdir -p "$INSTALL_DIR"

ENFORCE_SCRIPT="$INSTALL_DIR/yt_enforce.sh"
BLOCK_SCRIPT="$INSTALL_DIR/yt_block.sh"
UNBLOCK_SCRIPT="$INSTALL_DIR/yt_unblock.sh"
UNINSTALL_SCRIPT="$INSTALL_DIR/uninstall.sh"

# ═══════════════════════════════════════════════════════════════════
#  1. CREATE ENFORCE SCRIPT (Time-Aware)
#  ═══════════════════════════════════════════════════════════════════

cat << 'EOF' > "$ENFORCE_SCRIPT"
#!/bin/bash
HOUR=$(date +%H)
# Check if time is >= 18 (6 PM) and < 21 (9 PM)
if [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 21 ]; then
    /opt/youtube_lockdown/yt_unblock.sh
else
    /opt/youtube_lockdown/yt_block.sh
fi
EOF

# ═══════════════════════════════════════════════════════════════════
#  2. CREATE BLOCK SCRIPT
#  ═══════════════════════════════════════════════════════════════════

cat << 'EOF' > "$BLOCK_SCRIPT"
#!/bin/bash
DOMAINS="youtube.com www.youtube.com m.youtube.com youtu.be www.youtu.be youtubei.googleapis.com ytimg.com www.ytimg.com googlevideo.com"

# Remove old entries to prevent infinite duplicates
sed -i '/youtube\|ytimg\|googlevideo/d' /etc/hosts

# Append domains pointing to localhost
for d in $DOMAINS; do
    echo "127.0.0.1 $d" >> /etc/hosts
done

# Flush DNS if systemd-resolved is running
if command -v resolvectl &> /dev/null; then
    resolvectl flush-caches >/dev/null 2>&1
fi
EOF

# ═══════════════════════════════════════════════════════════════════
#  3. CREATE UNBLOCK SCRIPT
#  ═══════════════════════════════════════════════════════════════════

cat << 'EOF' > "$UNBLOCK_SCRIPT"
#!/bin/bash
# Remove all youtube/google video lines from hosts
sed -i '/youtube\|ytimg\|googlevideo/d' /etc/hosts

# Flush DNS if systemd-resolved is running
if command -v resolvectl &> /dev/null; then
    resolvectl flush-caches >/dev/null 2>&1
fi
EOF

# ═══════════════════════════════════════════════════════════════════
#  4. CREATE UNINSTALL SCRIPT
#  ═══════════════════════════════════════════════════════════════════

cat << 'EOF' > "$UNINSTALL_SCRIPT"
#!/bin/bash
if [ "$EUID" -ne 0 ]; then echo "Run as root."; exit 1; fi

echo "Removing YouTube Lockdown..."

# Stop and disable systemd timers
systemctl stop yt-lockdown.timer >/dev/null 2>&1
systemctl disable yt-lockdown.timer >/dev/null 2>&1
rm -f /etc/systemd/system/yt-lockdown.timer
rm -f /etc/systemd/system/yt-lockdown.service
systemctl daemon-reload

# Unblock YouTube
sed -i '/youtube\|ytimg\|googlevideo/d' /etc/hosts
if command -v resolvectl &> /dev/null; then resolvectl flush-caches >/dev/null 2>&1; fi

# Remove files
rm -rf /opt/youtube_lockdown

echo "Uninstalled successfully."
EOF

# ═══════════════════════════════════════════════════════════════════
#  MAKE SCRIPTS EXECUTABLE
#  ═══════════════════════════════════════════════════════════════════

chmod +x "$INSTALL_DIR"/*.sh

# ═══════════════════════════════════════════════════════════════════
#  5. CONFIGURE SYSTEMD SERVICE & TIMER
#  ═══════════════════════════════════════════════════════════════════

cat << EOF > /etc/systemd/system/yt-lockdown.service
[Unit]
Description=YouTube Lockdown Enforcer

[Service]
Type=oneshot
ExecStart=$ENFORCE_SCRIPT
EOF

cat << EOF > /etc/systemd/system/yt-lockdown.timer
[Unit]
Description=YouTube Lockdown Watchdog and Schedule

[Timer]
# Run 1 minute after boot
OnBootSec=1min
# Run every 5 minutes thereafter
OnUnitActiveSec=5min
# Force exact triggers on the boundary hours
OnCalendar=*-*-* 18:00:00
OnCalendar=*-*-* 21:00:00

[Install]
WantedBy=timers.target
EOF

# ═══════════════════════════════════════════════════════════════════
#  RELOAD DAEMON AND ENABLE
#  ═══════════════════════════════════════════════════════════════════

systemctl daemon-reload
systemctl enable --now yt-lockdown.timer >/dev/null 2>&1

# ═══════════════════════════════════════════════════════════════════
#  INITIALIZE CURRENT STATE
#  ═══════════════════════════════════════════════════════════════════

"$ENFORCE_SCRIPT"

echo ""
echo "========================================================="
echo "HOSTS-ONLY LOCKDOWN INSTALLED SUCCESSFULLY (ARCH LINUX)"
echo "========================================================="
echo "Allowed Time : 18:00 - 21:00"
echo "Directory    : $INSTALL_DIR"
echo ""
echo "To view timer status: systemctl list-timers | grep yt-lockdown"
echo "To uninstall        : sudo $UNINSTALL_SCRIPT"
echo "========================================================="
