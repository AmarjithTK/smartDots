# smartDots for Windows

**Author:** amarjith

smartDots is a productivity tool for Windows inspired by KDE Plasma's virtual desktop switcher. It uses AutoHotkey to provide fast keyboard shortcuts for switching desktops and other features.

## Features

- **Virtual Desktop Switcher:**  
  Use `Win+1`, `Win+2`, ..., `Win+9` to switch between virtual desktops, similar to KDE Plasma.
- **Custom Shortcuts:**  
  Easily add more shortcuts for window management, launching apps, and automation.
- **Dotfiles Storage:**  
  All configuration and dotfiles are stored in `C:/smartDots` for easy backup and portability.
- **Auto Startup:**  
  A shortcut is placed in `shell:startup` so smartDots runs automatically on login.

## Installation

1. **Clone or Download:**  
   Download the smartDots files and place them in `C:/smartDots`.

2. **AutoHotkey Required:**  
   Install [AutoHotkey](https://www.autohotkey.com/) if not already installed.

3. **Setup Startup Shortcut:**  
   Create a shortcut to the main smartDots script in `shell:startup`:
   - Press `Win+R`, type `shell:startup`, and press Enter.
   - Place a shortcut to `C:/smartDots/smartDots.ahk` in this folder.

4. **Configure Dotfiles:**  
   Store your custom configuration files (dotfiles) in `C:/smartDots`.

## Customization

- Edit `smartDots.ahk` to add or modify shortcuts.
- Add additional scripts or configuration files to `C:/smartDots`.

## Example Shortcuts

```ahk
; Win+1 to switch to desktop 1
#1::
    ; ...switch to desktop 1 code...
    return

; Win+2 to switch to desktop 2
#2::
    ; ...switch to desktop 2 code...
    return
```

## License

MIT License

---
