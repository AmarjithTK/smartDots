# SmartDots - Latest Edition of my dotfiles with GNU Stow

A modern dotfiles configuration with intelligent defaults and GNU Stow integration.

## Quick Install

```bash
git clone -b main2 --single-branch --depth 1 git@github.com:AmarjithTK/smartDots.git && bash ~/smartDots/setup.sh
```

Alternative method:
```bash
curl -Lo install.sh raw.github.usercontent/install.sh | bash install.sh | rm install.sh
```

![Desktop Preview](assets/scrot1.png)

## Current Features

* Arch Linux with multiple WM options:
  * BSPWM
  * DWM
  * XFCE (lightweight fallback)
* Shell & Terminal:
  * ZSH with custom configs
  * Rofi launcher
* Development Environment:
  * NVIM with NvChad
  * Preconfigured VSCodium with amVim extension
  * SSH autoconfig script
  * Automatic venv activation
  * AppImage management with launchers
* Fonts:
  * JetBrains Mono
  * Fira Code
* Legacy Features:
  * Firewall for NITC Students (Deprecated)

## Planned Improvements

### System & WM
- [ ] Workspace enhancements:
  - Window count indicator for monocle layout
  - ChatGPT workspace/scratchpad with keybinding
- [ ] Device-specific configurations via `devicespecificautostartetc.sh`
- [ ] System tray for BSPWM
- [ ] Scratchpad functionality (via tdrop)
- [ ] Dynamic wallpapers (mountain themes from unsplash)
- [ ] Conky configuration
- [ ] EWW widgets (low priority)

### Tools & Utilities
- [ ] FZF fuzzy finder integration
- [ ] Bluetooth management (bluez/blueberry replacement for blueman)
- [ ] Volume control:
  - Volume limiter
  - AutoEQ implementation
- [ ] Custom clipboard manager:
  - NodeJS backend
  - Time-based PIN security
  - Shortened URLs (bit.ly)
- [ ] Binary management:
  - Create `basescripts/binaries` folder
  - Add to PATH
  - Migrate frequently used scripts

### UI/UX Improvements
- [ ] Battery management:
  - Polybar battery indicator
  - Dunst notifications (30-40% threshold)
- [ ] Screen brightness control (brillo)
- [ ] Network indicators:
  - Better wlan0 name handling
  - Automatic eth0/wlan0 switching
- [ ] Dunst theming (Catppuccin)

### Documentation
- [ ] Vim cheatsheet (`:W` command)
- [ ] Cleanup redundant rofi launcher bindings
- [ ] Organize sxhkd configuration

### Cross-platform Support
- [ ] Windows setup script (Chocolatey-based)
- [ ] BAT file equivalents

### Automation
- [ ] Natural language processing for Google Calendar
- [ ] Audio-only playlist downloader
- [ ] Browser configuration:
```bash
unset BROWSER
xdg-settings set default-web-browser google-chrome.desktop
```

### Android Integration
Recommended apps:
- Media:
  - Namida (Video player)
  - Next Video player (with folder exclusion)
  - Musicolet
  - Wavelet
- Utilities:
  - VolumeLockr (custom mod planned)
  - LocalSend

## Contributing

Feel free to submit issues and enhancement requests.

## Browser Configuration
To set default browser:
```bash
unset BROWSER
xdg-settings set default-web-browser google-chrome.desktop
```

## Installation
Make sure to check the installation script before running:
```bash
curl -Lo install.sh raw.github.usercontent/install.sh | bash install.sh | rm install.sh
```