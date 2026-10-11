#!/usr/bin/env bash
# kwallet-scrub — remove KDE KWallet stack and keep it gone. Idempotent, runs as root.
set -u

PKGS=(
  kwalletmanager
  kwallet
  kwallet5
  kwallet-pam
  ksshaskpass
  signon-kwallet-extension
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

# Kill any running wallet daemons
for d in kwalletd6 kwalletd5 kwalletd; do
  if pkill -x "$d" 2>/dev/null; then
    echo "kwallet-scrub: killed $d"
  fi
done

# Strip autostart entries (system + every user) in case a package/hook recreated them
rm -f /etc/xdg/autostart/*kwallet* 2>/dev/null
rm -f /home/*/.config/autostart/*kwallet* 2>/dev/null

echo "kwallet-scrub: done at $(date -Is)"