#!/usr/bin/env bash
# kwallet-scrub — remove KDE KWallet + gnome-keyring stacks and keep them gone. Idempotent, runs as root.
set -u

PKGS=(
  kwalletmanager
  kwallet
  kwallet5
  kwallet-pam
  ksshaskpass
  signon-kwallet-extension
  gnome-keyring
)

present=()
for p in "${PKGS[@]}"; do
  pacman -Q "$p" >/dev/null 2>&1 && present+=("$p")
done

if [ ${#present[@]} -gt 0 ]; then
  echo "kwallet-scrub: removing ${present[*]}"
  # -Rdd: skip reverse-dep checks (drkonqi/juk/kaccounts-integration declare deps on kwallet)
  pacman -Rdd --noconfirm "${present[@]}" 2>&1 || echo "kwallet-scrub: pacman errors above (continuing cleanup)"
else
  echo "kwallet-scrub: no kwallet packages present"
fi

# Kill any running wallet/keyring daemons
for d in kwalletd6 kwalletd5 kwalletd gnome-keyring-daemon; do
  if pkill -x "$d" 2>/dev/null; then
    echo "kwallet-scrub: killed $d"
  fi
done

# Strip autostart entries (system + every user) in case a package/hook recreated them
rm -f /etc/xdg/autostart/*kwallet* 2>/dev/null
rm -f /home/*/.config/autostart/*kwallet* 2>/dev/null
rm -f /etc/xdg/autostart/*gnome-keyring* 2>/dev/null
rm -f /home/*/.config/autostart/*gnome-keyring* 2>/dev/null
# Drop any lingering user-unit enablement links (unit files leave with the package)
rm -f /home/*/.config/systemd/user/*/gnome-keyring-daemon* 2>/dev/null
rm -f /home/*/.config/systemd/user/*/gnome-keyring-* 2>/dev/null

echo "kwallet-scrub: done at $(date -Is)"