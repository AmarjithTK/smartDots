#!/usr/bin/env bash
# Install kwallet-scrub: script -> /usr/local/bin, units -> /etc/systemd/system, enable timer.
# Run with: sudo ~/.local/share/kwallet-scrub/install.sh
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }

install -Dm755 "$HERE/kwallet-scrub.sh"       /usr/local/bin/kwallet-scrub
install -Dm644 "$HERE/kwallet-scrub.service"  /etc/systemd/system/kwallet-scrub.service
install -Dm644 "$HERE/kwallet-scrub.timer"    /etc/systemd/system/kwallet-scrub.timer

systemctl daemon-reload
systemctl enable --now kwallet-scrub.timer
systemctl start kwallet-scrub.service   # immediate removal now

echo
echo "=== state ==="
systemctl is-enabled kwallet-scrub.timer
systemctl is-active kwallet-scrub.timer
journalctl -u kwallet-scrub.service -n 10 --no-pager