# smartDots — main4-plasma

KDE Plasma dotfiles bootstrap. Minimal files, maximum automation.

## Files

| File | What it does |
|---|---|
| [`aliasmanager.sh`](aliasmanager.sh) | ~89 aliases inline + `helper()` command — standalone, no dependencies |
| [`zsh-setup.sh`](zsh-setup.sh) | Installs ZSH + oh-my-zsh + powerlevel10k + generates `.zshrc` / `.zshconfig` |
| [`brillo-setup.sh`](brillo-setup.sh) | Installs Brillo KDE display brightness plasmoid widget |
| [`system-setup.sh`](system-setup.sh) | Menu-driven setup: base packages, ACPI backlight, GRUB, Git/SSH, TLP |
| [`vscode-setup.sh`](vscode-setup.sh) | Installs VSCodium + Material Theme + vim + Flutter extensions |
| [`.gitconfig`](.gitconfig) | Git configuration — copy to `~/` |
| [`.gitignore_global`](.gitignore_global) | Global gitignore rules — copy to `~/` |

## Quick Start

```bash
# 1. Aliases (source for immediate use)
. ./aliasmanager.sh

# 2. System setup (packages, backlight, GRUB, etc.)
bash system-setup.sh

# 3. ZSH environment
bash zsh-setup.sh

# 4. Brillo KDE brightness widget
bash brillo-setup.sh

# 5. Git config
cp .gitconfig ~/
cp .gitignore_global ~/
```

## Adding New Aliases

```bash
# 1. Edit aliasmanager.sh — add one line to the ALIASES array:
#    "category|alias|command"

# 2. Regenerate the registry:
bash aliasmanager.sh --generate

# 3. Re-source:
. aliasmanager.sh
# Done.
```

## Branches

| Branch | Description |
|---|---|
| `main3` | Full smartDots ecosystem (bspwm, polybar, stow packages) |
| `main4-plasma` | **Current** — KDE Plasma bootstrap (aliasmanager + ZSH + Brillo + system-setup) |
