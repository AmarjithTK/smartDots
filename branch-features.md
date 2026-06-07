# Branch Features Overview

This document describes the features of the two primary branches in the [`smartDots`](https://github.com/AmarjithTK/smartDots) repository: [`main2`](https://github.com/AmarjithTK/smartDots/tree/main2) (Linux) and [`windows`](https://github.com/AmarjithTK/smartDots/tree/windows).

---

## Table of Contents

- [main2 (Linux — Default Branch)](#main2-linux--default-branch)
  - [Core System & Management](#core-system--management)
  - [Window Managers & Desktop](#window-managers--desktop)
  - [Shell & Terminal](#shell--terminal)
  - [Development Environment](#development-environment)
  - [Utilities & Automation](#utilities--automation)
  - [Configuration & Dotfiles Architecture](#configuration--dotfiles-architecture)
  - [Docker](#docker)
  - [Installation](#installation)
- [windows (Windows — KDE Plasma-like Setup)](#windows-windows--kde-plasma-like-setup)
  - [Features](#features-1)
  - [Installation](#installation-1)
- [Diff Summary](#diff-summary)

---

## main2 (Linux — Default Branch)

The [`main2`](https://github.com/AmarjithTK/smartDots/tree/main2) branch is the primary Linux dotfiles management system using **GNU Stow** to symlink configurations across the home directory. It supports multiple window managers, advanced shell configuration, and a streamlined development environment.

### Core System & Management

| Feature | Description |
|---------|-------------|
| **GNU Stow Integration** | Dotfiles are managed via [`setup.sh`](setup.sh) which runs `stow -d ~/smartDots -t ~ dotfiles` to symlink all configurations. |
| **Modular Setup System** | [`runner.sh`](dotfiles/basescripts/runner.sh) provides an interactive menu to execute individual `.setup` scripts. |
| **Package Management** | [`basepackages.setup`](dotfiles/basescripts/configs/basepackages.setup) installs Arch Linux packages from a curated list in [`basepackages.txt`](dotfiles/basescripts/configs/artifacts/basepackages.txt). |
| **Arch Linux Keyring Recovery** | The `spu` alias handles emergency Arch Linux keyring recovery before full system update. |
| **Mirrorlist Management** | `reflect` alias runs `reflector` to fetch the fastest 20 HTTPS mirrors. |
| **Power Profiles** | Quick power profile switching: `powerlow`, `powerbalance`, `powerperformance`, `powerstatus` via `powerprofilesctl`. |
| **Distrobox Integration** | Seamless integration with Distrobox containers (`archie`, `archway`, `archdown`, `archwipe`, `archlist` aliases) — run commands inside an `archlinux:latest` container. |

### Window Managers & Desktop

| Feature | Description |
|---------|-------------|
| **BSPWM** | Pre-configured BSPWM setup with custom keybindings in [`bspwm-sxhdrc`](dotfiles/.config/sxhkd/bspwm-sxhdrc) and [`bspwmrc`](dotfiles/.config/bspwm/bspwmrc). |
| **DWM** | DWM build support with `smci` alias for `make clean install`. Backup config in [`dwm.bak`](dotfiles/basescripts/configs/archives/dwm.bak). |
| **XFCE** | Lightweight fallback desktop environment. |
| **KDE Plasma** | Autostart script [`autostart_plasma.sh`](dotfiles/basescripts/utilities/autostart_plasma.sh) for KDE Plasma sessions. |
| **Polybar** | Custom polybar configuration with system tray, network indicators (wlan0/eth0 switching), battery indicator, and time element. Backup config preserved. |
| **Picom Compositor** | Compositor config for smooth rendering and transparency. |
| **Rofi Launcher** | Application launcher configured with Nord theme. |
| **sxhkd** | Hotkey daemon configured for both standalone and BSPWM sessions. |
| **Dunst Notifications** | Notification daemon configured with Nord/Catppuccin theming. |
| **LightDM Slick Greeter** | Dynamic daily wallpaper script via [`greeterwall.sh`](dotfiles/basescripts/utilities/greeterwall.sh). |
| **System Tray** | Network Manager applet and other system tray items. |

### Shell & Terminal

| Feature | Description |
|---------|-------------|
| **ZSH** | Custom ZSH configuration with Powerlevel10k prompt, history retention (`HISTSIZE=10000`), and append history options. |
| **Kitty Terminal** | Terminal emulator configured with Nord theme, full config at [`kitty.conf`](dotfiles/.config/kitty/kitty.conf). |
| **Aliases** | Comprehensive alias set in [`aliases.txt`](dotfiles/.helpers/aliases.txt) covering system management, git, development, and miscellaneous tasks. |
| **ZSH History** | Configured for append history mode to retain history across sessions. |

### Development Environment

| Feature | Description |
|---------|-------------|
| **NVIM (NvChad)** | Neovim configured with NvChad framework via [`nvim.setup`](dotfiles/basescripts/configs/nvim.setup). |
| **VSCodium** | Visual Studio Code configured with amVim extension via [`vscode.setup`](dotfiles/basescripts/configs/vscode.setup). |
| **Python Virtualenv** | Automatic Python virtual environment activation with `venvcmd` alias and [`venvmanager`](dotfiles/basescripts/utilities/binaries/venvmanager) binary script. `python-virtualenvwrapper` is installed. |
| **AppImage Manager** | Script [`appimagemanager.sh`](dotfiles/basescripts/utilities/binaries/appimagemanager.sh) for managing AppImage applications with launchers. |
| **Flutter SDK** | Flutter SDK path added to `$PATH` in [`zshconfig`](dotfiles/.zshconfig). |
| **SSH** | Custom SSH helper alias `sshb` for connecting on port 2222. |
| **Binary Management** | Custom binaries directory at `~/basescripts/utilities/binaries` added to `$PATH`, containing launchers for JIOTV, dmenu-powermenu, and more. |

### Utilities & Automation

| Feature | Description |
|---------|-------------|
| **Brightness Control** | [`brightness_control.sh`](dotfiles/basescripts/utilities/brightness_control.sh) — controls any display brightness using `ddcutil` with device-specific hostname detection. |
| **Color Temperature** | [`colortemp.sh`](dotfiles/basescripts/utilities/colortemp.sh) — adjust screen color temperature. |
| **Sleep Timer** | [`sleepr.sh`](dotfiles/basescripts/utilities/sleepr.sh) — set a sleep timer with audio playback check and Zenity popup to shutdown. |
| **Bedtime Reminder** | [`bedtime.sh`](dotfiles/basescripts/utilities/bedtime.sh) — bedtime reminder with auto-shutdown capability. |
| **Scratchpads** | [`scpad.sh`](dotfiles/basescripts/utilities/scpad.sh) — tdrop-based scratchpad for Firefox and other apps with fullscreen toggle support. |
| **GPT Scratchpad** | [`gptscratchpad.sh`](dotfiles/basescripts/utilities/gptscratchpad.sh) — ChatGPT workspace/scratchpad keybinding for KDE Plasma. |
| **Wallpaper Management** | [`walld`](dotfiles/basescripts/utilities/binaries/walld) — wallpaper daemon. [`wallfetch`](dotfiles/basescripts/utilities/binaries/wallfetch) — fetch and set wallpapers with `feh`. [`sfwallpaper.sh`](dotfiles/basescripts/utilities/sfwallpaper.sh) — Special Forces themed wallpaper generator. |
| **Idle Notification** | [`notify2.sh`](dotfiles/basescripts/utilities/notify2.sh) — notify-idle script with audio playback detection, auto-shutdown via Zenity popup, and autostart on Plasma login. |
| **Battery Notifications** | [`notifybattery.sh`](dotfiles/basescripts/utilities/notifybattery.sh) — low battery audio alerts and charging status detection. |
| **Grayscale Toggle** | [`grayscale_toggle.sh`](dotfiles/basescripts/utilities/grayscale_toggle.sh) — toggle monitor grayscale (credits: [bubbleguuum](https://github.com/bubbleguuum/toggle-monitor-grayscale)). |
| **Chrome Rofi** | [`chrome_rofi.sh`](dotfiles/basescripts/utilities/chrome_rofi.sh) — quick access to Chrome profiles via Rofi. |
| **Volume Regulator** | Volume limiter with timeout to prevent misuse, device-specific via hostname. |
| **Clipboard** | `xclip` integration for clipboard management with `copy` alias and `copyn` function for copying N lines. |
| **5-Minute Timer** | [`5minutes.sh`](dotfiles/basescripts/utilities/5minutes.sh) — a 5-minute timer utility. |
| **Pushup Reminder** | [`pushup.sh`](dotfiles/basescripts/utilities/pushup.sh) — periodic pushup reminder. |
| **Shrutibox** | [`shrutibox.sh`](dotfiles/basescripts/utilities/shrutibox.sh) — music helper utility. |
| **Powermenu** | Rofi-based powermenu at [`powermenu-rofi.sh`](dotfiles/basescripts/utilities/powermenu-rofi.sh) with dmenu variant. |
| **Pacman Update** | [`pacmanupdate.sh`](dotfiles/basescripts/utilities/pacmanupdate.sh) — quick update checker. |
| **WiFi Menu** | `nmtui` alias for WiFi connectivity. |
| **Firefox Theme** | [`firefoxtheme.setup`](dotfiles/basescripts/configs/firefoxtheme.setup) and [`userChrome.css`](dotfiles/.config/firefox/userChrome.css) for custom Firefox theming. |
| **JIO TV** | JIOTV Go binary launcher with sxhkd shortcut. |
| **Autostart** | Device-specific autostart via [`autostart.sh`](dotfiles/basescripts/utilities/autostart.sh) using hostname detection. |

### Configuration & Dotfiles Architecture

| File | Purpose |
|------|---------|
| [`dotfiles/.gitconfig`](dotfiles/.gitconfig) | Git global configuration |
| [`dotfiles/.gitignore_global`](dotfiles/.gitignore_global) | Global gitignore rules |
| [`dotfiles/.zshrc`](dotfiles/.zshrc) | ZSH runtime configuration |
| [`dotfiles/.zshconfig`](dotfiles/.zshconfig) | ZSH environment variables, PATH, aliases, and power profiles |
| [`dotfiles/basescripts/configs/`](dotfiles/basescripts/configs/) | Modular setup scripts (base packages, Firefox theme, NVIM, VSCode, ZSH) |
| [`dotfiles/basescripts/configs/archives/`](dotfiles/basescripts/configs/archives/) | Backup config archives (cron, dwm, git-crypt, git, laptop, nix, theme) |
| [`dotfiles/.helpers/`](dotfiles/.helpers/) | Helper files (aliases, brightness, cron, extensions, music, programs, venvcmd) |

### Docker

| Feature | Description |
|---------|-------------|
| **WordPress** | [`dotfiles/docker/wordpress/docker-compose.yml`](dotfiles/docker/wordpress/docker-compose.yml) — Docker Compose setup for WordPress. |

### Installation

```bash
# Method 1: Clone and run
git clone -b main2 --single-branch --depth 1 git@github.com:AmarjithTK/smartDots.git ~/smartDots
bash ~/smartDots/setup.sh

# Method 2: One-liner install
curl -Lo install.sh https://raw.githubusercontent.com/AmarjithTK/smartDots/main2/install.sh
bash install.sh
```

---

## windows (Windows — KDE Plasma-like Setup)

The [`windows`](https://github.com/AmarjithTK/smartDots/tree/windows) branch is a lightweight Windows productivity setup inspired by KDE Plasma's virtual desktop switcher. It uses **AutoHotkey** to provide fast keyboard shortcuts for virtual desktop management.

### Files

| File | Purpose |
|------|---------|
| [`README.md`](README.md) | Branch documentation and setup instructions |
| [`VirtualDesktopAccessor.dll`](VirtualDesktopAccessor.dll) | DLL (354 KB) providing the Windows virtual desktop API for AutoHotkey (by Ciantic) |
| [`window_switcher.ahk`](window_switcher.ahk) | AutoHotkey v2 script implementing plasma-like virtual desktop navigation |

### Features

| Feature | Description |
|---------|-------------|
| **Virtual Desktop Switching** | Switch between Windows 10/11 virtual desktops using `Win+1` through `Win+9`, similar to KDE Plasma's desktop grid. |
| **AutoHotkey v2** | Modern AHK v2 script leveraging `VirtualDesktopAccessor.dll` for native virtual desktop API access. |
| **Desktop Count Detection** | Dynamically detects the number of available virtual desktops via `GetDesktopCount()` to prevent invalid switches. |
| **Zero-based Indexing** | Internally converts 1-based hotkey numbers to 0-based DLL calls for correct desktop targeting. |
| **Minimal Footprint** | Only 3 files — simple, lightweight, and easy to customize. |
| **Auto Startup** | Place a shortcut in `shell:startup` for automatic startup on login. |
| **Portable** | All files stored in `C:/smartDots` for easy backup and transfer. |

### Installation

```bash
1. Install AutoHotkey v2 from https://www.autohotkey.com/
2. Copy smartDots files to C:/smartDots
3. Create shortcut to window_switcher.ahk in shell:startup
```

---

## Diff Summary

The [`windows`](https://github.com/AmarjithTK/smartDots/tree/windows) branch is a complete departure from [`main2`](https://github.com/AmarjithTK/smartDots/tree/main2):

| Aspect | main2 (Linux) | windows (Windows) |
|--------|---------------|-------------------|
| **Target OS** | Arch Linux | Windows 10/11 |
| **Config Management** | GNU Stow symlink farm | Manual folder setup (`C:/smartDots`) |
| **Key Technology** | BSPWM, ZSH, Polybar, Rofi, Picom | AutoHotkey v2 |
| **Number of Files** | ~60+ files (dotfiles, scripts, configs) | 3 files |
| **Primary Function** | Full dotfiles ecosystem | Virtual desktop switcher only |
| **Automation** | Modular setup scripts (`runner.sh` + `.setup` files) | Simple AHK script + startup folder |
| **Package Manager** | pacman, yay, distrobox | Chocolatey (planned) |

---

> **Note:** The Windows branch was intentionally kept minimal — containing only the essential virtual desktop switcher — while the Linux `main2` branch evolved into a comprehensive dotfiles management system with extensive utilities, window manager support, and development tooling.
