# Archive — BSPWM / Polybar / Picom / sxhkd Configs

These configs are for **window manager-based setups (BSPWM, DWM)** and are not actively used with KDE Plasma. They are preserved here for reference.

## Contents

| Directory | Contents | Original Source |
|-----------|----------|----------------|
| `stow/bspwm/` | BSPWM window manager config | `main2:dotfiles/.config/bspwm/bspwmrc` |
| `stow/sxhkd/` | Standalone + BSPWM hotkey daemon configs | `main2:dotfiles/.config/sxhkd/` |
| `stow/polybar/` | Polybar status bar config | `main2:dotfiles/.config/polybar/config.ini` |
| `stow/picom/` | Picom compositor config | `main2:dotfiles/.config/picom/picom.conf` |
| `bin/` | WM-dependent scripts (scratchpad, dmenu, grayscale, etc.) | `main2:dotfiles/basescripts/utilities/` |
| `setup/` | LightDM greeter wallpaper | `main2:dotfiles/basescripts/utilities/greeterwall.sh` |

## Restoring

If you switch back to BSPWM, use the bootstrap menu:
```bash
bash linux/setup/bootstrap.sh
# Option 4: Archive stow
```

Or manually:
```bash
cd ~/smartDots
stow -d archive/stow -t ~ bspwm
stow -d archive/stow -t ~ sxhkd
stow -d archive/stow -t ~ polybar
stow -d archive/stow -t ~ picom
```
