# smartDots — Cross-Platform Dotfiles

**Author:** AmarjithTK

A unified dotfiles repository supporting **Linux (KDE Plasma)** and **Windows (AutoHotkey)** with a clean, simplified structure.

> **Default branch:** `main3` — orphan branch with fresh start, no history.
> Linux configs: `main2` branch • Windows configs: `windows` branch

---

## Quick Start

### Linux (KDE Plasma) — SSH-First Install
```bash
bash <(curl -sL https://raw.githubusercontent.com/AmarjithTK/smartDots/main3/install.sh)
```

The installer will:
1. Attempt **SSH clone** (recommended for updates)
2. If SSH fails → check for SSH keys
3. No key? → **Auto-generate** ed25519 key pair
4. Try **`gh` CLI** upload to GitHub automatically
5. Show **pretty-printed public key** + clickable GitHub URL
6. **HTTPS fallback** as last resort

### Windows (AutoHotkey)
```powershell
git clone -b main3 https://github.com/AmarjithTK/smartDots.git
cd smartDots/windows
powershell -ExecutionPolicy Bypass -File install.ps1
```

---

## Directory Structure

```
smartDots/
├── install.sh                  # Cross-platform installer (detects OS)
├── linux/
│   ├── setup/                  # Setup scripts (packages, devtools, firefox, bootstrap)
│   ├── stow/                   # GNU Stow dotfiles (active — KDE-compatible)
│   │   ├── shell/              # .zshrc, .zshconfig
│   │   ├── kitty/              # Kitty terminal config
│   │   ├── rofi/               # Rofi launcher config
│   │   ├── dunst/              # Dunst notification config
│   │   ├── firefox/            # userChrome.css
│   │   └── plasma-autostart/   # KDE autostart .desktop files
│   ├── bin/                    # 12 consolidated CLI utilities
│   ├── helpers/                # Aliases, audio files
│   └── docker/                 # Docker compose files
├── windows/
│   ├── window_switcher.ahk     # KDE Plasma-like virtual desktop switcher
│   ├── VirtualDesktopAccessor.dll
│   └── install.ps1             # Windows PowerShell installer
├── shared/
│   └── git/                    # Cross-platform git configs
├── archive/                    # BSPWM/Polybar/Picom configs (reference only)
└── assets/                     # Screenshots
```

---

## Linux Features (KDE Plasma)

### 📺 Display Manager — `display-manager`
| Subcommand | Description |
|-----------|-------------|
| `brightness inc` | Increase brightness by 5% |
| `brightness dec` | Decrease brightness by 5% |
| `colortemp inc` | Increase color temperature |
| `colortemp dec` | Decrease color temperature (warmer) |

### 🖼️ Wallpaper Manager — `wallpaper`
| Subcommand | Description |
|-----------|-------------|
| `fetch` | Daily Unsplash wallpaper with dedup |
| `random` | Random Unsplash on demand |
| `pexels` | Special Forces from Pexels (requires `.env`) |

### 🔄 Reminder Daemon — `reminder-daemon`
| Subcommand | Description |
|-----------|-------------|
| `pushup` | 30-min push-up reminder |
| `timer` | 5-min beep timer |
| `bedtime [HH:MM]` | Shutdown at specified time |
| `sleepr` | Late-night harassment mode |
| `shrutibox --toggle` | Toggle MP3 loop playback |

### ⚡ Power Menu — `powermenu`
Lock, logout, reboot, shutdown via rofi/dmenu (auto-detects).

### 🔧 Config Editor — `config-editor`
Quickly edit config files (zshrc, kitty, rofi, dunst, etc.) via rofi/dmenu.

### 🎵 YouTube Downloader — `yt-dlp`
Audio or video download via yt-dlp with quality selection.

### 🛡️ System Monitors
| Command | Description |
|---------|-------------|
| `idle-monitor` | Detects idle + media playback → shutdown dialog |
| `battery-monitor` | Alerts when battery < 45% and not charging |
| `check-updates` | Check Arch Linux package updates |

### 🌐 Web Launcher — `web-launcher`
Open ChatGPT, Claude, Notion, Gmail, YouTube, etc. in Chrome via rofi.

### 🧰 Utilities
| Command | Description |
|---------|-------------|
| `appimage install\|delete` | Manage AppImage applications |
| `venv` | Python virtual environment manager |
| `check-updates` | Check system updates |

### Dev Setup
```bash
bash linux/setup/bootstrap.sh
```
Menu options: base packages, dev tools (ZSH + NvChad + VSCodium), Firefox theme.

---

## Windows Features

- **KDE Plasma-like virtual desktop navigation** using `Win+1`..`Win+9`
- Powered by AutoHotkey v2 + VirtualDesktopAccessor.dll
- Minimal footprint — 3 files, no bloat
- Automatic startup via `shell:startup`

### Installation
```powershell
powershell -ExecutionPolicy Bypass -File windows/install.ps1
```

---

## Development

### Adding new scripts
1. Add to `linux/bin/` with `--help` support
2. Make executable (`chmod +x`)
3. The script will be auto-installed by `bootstrap.sh`

### Archiving configs
If switching away from KDE Plasma, BSPWM/Polybar/Picom configs are available in `archive/`:
```bash
bash linux/setup/bootstrap.sh
# Select option 4 from the menu
```

---

## License

MIT License
