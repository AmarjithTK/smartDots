# kwallet-scrub

Removes the KDE KWallet stack and keeps it gone — even if `pacman -Syu` or a
group install drags it back.

**Packages removed:** `kwallet`, `kwallet5`, `kwalletmanager`, `kwallet-pam`,
`ksshaskpass`, `signon-kwallet-extension` (via `pacman -Rdd`, bypassing
drkonqi/juk/kaccounts-integration reverse-deps).

Also kills running `kwalletd6`/`kwalletd5` and strips `/etc/xdg/autostart`
and per-user `~/.config/autostart` KWallet entries.

## Install (once, needs sudo)

```sh
sudo ./install.sh
```

Installs the script to `/usr/local/bin/kwallet-scrub`, units to
`/etc/systemd/system/`, enables the timer, and runs the first scrub.

## Timer schedule

- `OnBootSec=3min` — 3 minutes after boot
- `OnUnitInactiveSec=6h` — every 6 hours after the last run
- `Persistent=true` — catches runs missed while powered off

## Manage

```sh
systemctl status kwallet-scrub.timer
journalctl -u kwallet-scrub.service -f
kwallet-scrub          # manual run
```

Note: wallet *data* in `~/.local/share/kwallet/` is left untouched (inert
without the software).