#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
#  aliasmanager — standalone alias bootstrap
#  ═══════════════════════════════════════════════════════════════════
#  One file. Source it. Aliases ready.
#  No external dependencies. No smartDots required.
#
#  USAGE:
#    . aliasmanager.sh                       # Source → aliases + helper ready
#    bash aliasmanager.sh                    # Sync + regenerate registry
#    bash aliasmanager.sh --list             # Show all categories
#    bash aliasmanager.sh --install          # Add source line to shell config
#    bash aliasmanager.sh --help             # Show this help
#
#  ADDING ALIASES:
#    1. Edit the ALIASES array below (one line per entry)
#    2. Run: bash aliasmanager.sh          # syncs ~/.aliasmanager/ + registry
#    3. Run: . ~/.aliasmanager/aliasmanager.sh   # apply to current shell
#    Done. That's it.
#  ═══════════════════════════════════════════════════════════════════

ALIASMAN_DIR="${ALIASMAN_DIR:-$HOME/.aliasmanager}"
REGISTRY="$ALIASMAN_DIR/registry.txt"

# ═══════════════════════════════════════════════════════════════════
#  ALIASES — Master List
#  ═══════════════════════════════════════════════════════════════════
#  Format: "category|alias|command"
#  ▼ Add new entries here. One place. ▼

ALIASES=(

  # ── Flutter ──────────────────────────────────────────────────
  "flutter|fpg|flutter pub get"
  "flutter|fpc|flutter pub cache repair"
  "flutter|fpu|flutter pub upgrade"
  "flutter|fc|flutter clean"
  "flutter|fcp|flutter clean && flutter pub get"
  "flutter|fr|flutter run"
  "flutter|frc|flutter run -d chrome"
  "flutter|frw|flutter run -d web-server"
  "flutter|frl|flutter run -d linux"
  "flutter|fra|flutter run -d android"
  "flutter|fba|flutter build apk"
  "flutter|fbas|flutter build apk --split-per-abi"
  "flutter|fbaa|flutter build appbundle"
  "flutter|fbw|flutter build web"
  "flutter|fbl|flutter build linux"
  "flutter|fan|flutter analyze"
  "flutter|ffix|dart fix --apply"

  # ── Git ──────────────────────────────────────────────────────
  "git|gs|git status"
  "git|gl|git log --oneline --graph"
  "git|gd|git diff"
  "git|ga|git add ."
  "git|gau|git add -u"
  "git|gap|git add -p"
  "git|gc|git commit"
  "git|gcm|git commit -m"
  "git|gca|git add . && git commit -m"
  "git|gcap|git add . && git commit -m && git push"
  "git|gp|git pull"
  "git|gps|git push"
  "git|gpsu|git push -u origin HEAD"
  "git|gb|git branch"
  "git|gco|git checkout"
  "git|gsw|git switch"

  # ── NPM ──────────────────────────────────────────────────────
  "npm|ni|npm install"
  "npm|nid|npm install --save-dev"
  "npm|ns|npm start"
  "npm|nd|npm run dev"
  "npm|nb|npm run build"
  "npm|nt|npm test"
  "npm|nr|npm run"

  # ── PNPM ─────────────────────────────────────────────────────
  "pnpm|pi|pnpm install"
  "pnpm|pd|pnpm dev"
  "pnpm|pb|pnpm build"

  # ── Bun ──────────────────────────────────────────────────────
  "bun|bi|bun install"
  "bun|bd|bun dev"
  "bun|bb|bun build"

  # ── Docker ───────────────────────────────────────────────────
  "docker|dps|docker ps"
  "docker|dimg|docker images"
  "docker|dc|docker compose"
  "docker|dcu|docker compose up"
  "docker|dcd|docker compose down"
  "docker|dcl|docker compose logs"

  # ── System ───────────────────────────────────────────────────
  "system|ll|ls -lah"
  "system|la|ls -A"
  "system|c|clear"
  "system|h|history"
  "system|p|pwd"
  "system|myip|curl ifconfig.me"
  "system|ports|ss -tulpn"

  # ── Pacman / Package Management ──────────────────────────────
  "pacman|spy|sudo pacman -Sy"
  "pacman|sp|sudo pacman -S --noconfirm"
  "pacman|spr|sudo pacman -R"
  "pacman|spu|sudo pacman -S archlinux-keyring --noconfirm && sudo pacman -Syu"
  "pacman|reflect|sudo reflector --latest 20 --protocol https --save /etc/pacman.d/mirrorlist"
  "yay|ypy|yay -S"
  "yay|yp|yay -S --noconfirm"

  # ── Systemctl ────────────────────────────────────────────────
  "systemctl|senable|sudo systemctl enable"
  "systemctl|sdisable|sudo systemctl disable"
  "systemctl|sstart|sudo systemctl start"
  "systemctl|sstop|sudo systemctl stop"
  "systemctl|srestart|sudo systemctl restart"
  "systemctl|sstatus|sudo systemctl status"

  # ── Power Profiles ───────────────────────────────────────────
  "power|powerlow|powerprofilesctl set power-saver"
  "power|powerbalance|powerprofilesctl set balanced"
  "power|powerperformance|powerprofilesctl set performance"
  "power|powerstatus|powerprofilesctl"

  # ── Distrobox ────────────────────────────────────────────────
  "distrobox|a|distrobox enter archbox --"
  "distrobox|ax|distrobox export --app"
  "distrobox|archie|distrobox enter archbox"
  "distrobox|archway|distrobox create --name archbox --image archlinux:latest"
  "distrobox|archdown|distrobox stop archbox"
  "distrobox|archwipe|distrobox rm archbox"
  "distrobox|archlist|distrobox list"

  # ── Editor / Utilities ───────────────────────────────────────
  "utils|vi|nvim"
  "utils|vim|nvim"
  "utils|mkp|mkdir -p"
  "utils|copy|xclip -selection clipboard"
  "utils|copyclip|xclip -selection clipboard"
  "utils|wifimenu|nmtui"
)

# ═══════════════════════════════════════════════════════════════════
#  SHELL FUNCTIONS (multi-step — too complex for aliases)
#  ═══════════════════════════════════════════════════════════════════

# Install Flutter APK to all connected ADB devices in parallel
# Usage: finstall [path/to/app.apk]
finstall() {
  local apk="${1:-build/app/outputs/flutter-apk/app-arm64-v8a-release.apk}"
  local devices
  devices=$(adb devices | tail -n +2 | grep -v "^$" | cut -sf 1)
  if [ -z "$devices" ]; then
    echo "No ADB devices found"
    return 1
  fi
  echo "$devices" | xargs -I {} -P 4 adb -s {} install -r "$apk"
}

# ═══════════════════════════════════════════════════════════════════
#  FUNCTIONS
#  ═══════════════════════════════════════════════════════════════════

# ─── generate: write registry.txt from ALIASES array ──────────────
generate_registry() {
  mkdir -p "$ALIASMAN_DIR"
  {
    echo "# aliasmanager — Alias Registry"
    echo "# Auto-generated by aliasmanager.sh"
    echo "# Format: category|alias|command"
    echo "#"
    for entry in "${ALIASES[@]}"; do
        echo "$entry"
      done
    } > "$REGISTRY"
    local count
    count=$(grep -c '^[a-z]' "$REGISTRY" 2>/dev/null || echo 0)
    echo "$count"
}

# ─── load: define all aliases for current shell ───────────────────
load_aliases() {
  if [ ! -f "$REGISTRY" ]; then
    generate_registry >/dev/null
  fi
  while IFS='|' read -r category alias_name command; do
    case "$category" in ''|\#*) continue ;; esac
    alias "$alias_name"="$command" 2>/dev/null || true
  done < "$REGISTRY"
}

# ─── helper: list/search aliases by category ──────────────────────
helper() {
  local filter="${1:-}"
  if [ ! -f "$REGISTRY" ]; then
    echo "Registry not found. Run: bash aliasmanager.sh --generate"
    return 1
  fi
  if [ -z "$filter" ]; then
    awk -F'|' '
    /^[a-z]/ {
      if ($1 != prev) {
        title = toupper(substr($1,1,1)) substr($1,2)
        print "\n=== " title " ==="
        prev = $1
      }
      printf "  %-12s %s\n", $2, $3
    }' "$REGISTRY"
  else
    awk -F'|' -v f="$filter" '
    /^[a-z]/ && tolower($0) ~ tolower(f) {
      if ($1 != prev) {
        title = toupper(substr($1,1,1)) substr($1,2)
        print "\n=== " title " ==="
        prev = $1
      }
      printf "  %-12s %s\n", $2, $3
    }' "$REGISTRY"
  fi
}

# ─── list categories ──────────────────────────────────────────────
list_categories() {
  echo "Available categories:"
  for entry in "${ALIASES[@]}"; do
    echo "  ${entry%%|*}"
  done | sort -u
}

# ─── install: add source line to shell config ─────────────────────
install_self() {
  local rcfile=""
  case "$(basename "${SHELL:-bash}")" in
    zsh)  rcfile="$HOME/.zshrc" ;;
    bash) rcfile="$HOME/.bashrc" ;;
    *)    rcfile="$HOME/.profile" ;;
  esac

  # Determine script path
  local script_path
  if [ -n "${BASH_SOURCE[0]:-}" ]; then
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
  else
    script_path="$HOME/.aliasmanager/aliasmanager.sh"
  fi

  local source_line=". \"$script_path\""
  if ! grep -q "aliasmanager" "$rcfile" 2>/dev/null; then
    { echo ""; echo "# aliasmanager — standalone alias bootstrap"; echo "$source_line"; } >> "$rcfile"
    echo "  Added source line to $rcfile"
  else
    echo "  aliasmanager already sourced in $rcfile"
  fi

  # Create symlink in ~/.local/bin for CLI access
  local bindir="$HOME/.local/bin"
  mkdir -p "$bindir"
  if [ ! -f "$bindir/aliasmanager" ]; then
    ln -s "$script_path" "$bindir/aliasmanager"
    echo "  Created: $bindir/aliasmanager → aliasmanager"
  else
    echo "  $bindir/aliasmanager already exists"
  fi
}

# ─── show help ────────────────────────────────────────────────────
show_help() {
  cat <<'HELP'
aliasmanager.sh — standalone alias bootstrap

USAGE:
  . aliasmanager.sh              Source → aliases + helper ready
  bash aliasmanager.sh           Sync → copies to ~/.aliasmanager/ + regenerates registry
  bash aliasmanager.sh --list    Show all categories
  bash aliasmanager.sh --install Add source line to shell config
  bash aliasmanager.sh --help    Show this help

AFTER SOURCING:
  helper                  List all aliases by category
  helper git              Filter by category or keyword

ADDING NEW ALIASES:
  1. Edit the ALIASES array in aliasmanager.sh
  2. Run: bash aliasmanager.sh          # syncs ~/.aliasmanager/ + registry
  3. Run: . ~/.aliasmanager/aliasmanager.sh   # apply to current shell
  Done.

EXAMPLE:
  Add "docker|dprune|docker system prune -af"
  → bash aliasmanager.sh
  → . ~/.aliasmanager/aliasmanager.sh
  → dprune  # works instantly
HELP
}

# ═══════════════════════════════════════════════════════════════════
#  MAIN / CLI
#  ═══════════════════════════════════════════════════════════════════

# ─── Detect if script is being sourced or executed ───────────────
# Works in both bash and zsh.
is_sourced() {
  if [ -n "$ZSH_EVAL_CONTEXT" ]; then
    case $ZSH_EVAL_CONTEXT in *:file:*) return 0;; esac
    return 1
  elif [ -n "$BASH_SOURCE" ] && [ "${BASH_SOURCE[0]}" != "$0" ]; then
    return 0
  fi
  return 1
}

# ─── When executed (bash aliasmanager.sh): sync + regenerate + guide ──
# ─── When sourced (. aliasmanager.sh):        sync + regenerate + load ──
sync_and_source() {
  # 1. Copy self to ~/.aliasmanager/ for persistence
  local src_path
  if [ -n "${BASH_SOURCE[0]:-}" ]; then
    src_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)/$(basename "${BASH_SOURCE[0]}")"
  elif [ -n "$ZSH_SCRIPT" ]; then
    src_path="$ZSH_SCRIPT"
  else
    src_path="./aliasmanager.sh"
  fi

  local dst="$HOME/.aliasmanager/aliasmanager.sh"
  mkdir -p "$HOME/.aliasmanager"
  if [ -f "$src_path" ]; then
    cp "$src_path" "$dst"
  fi

  # 2. Regenerate registry (always — picks up edits)
  generate_registry >/dev/null

  # 3. If sourced → load aliases into current shell
  #    If executed → tell user to re-source
  if is_sourced; then
    load_aliases
  else
    echo "✅ aliasmanager synced — run: . ~/.aliasmanager/aliasmanager.sh"
  fi
}

case "${1:-}" in
  --generate|-g)
    generate_registry
    ;;
  --load|-l)
    generate_registry >/dev/null
    load_aliases
    ;;
  --list)
    list_categories
    ;;
  --install|-i)
    install_self
    ;;
  --help|-h)
    show_help
    ;;
  "")
    sync_and_source
    ;;
  *)
    echo "Unknown option: $1"
    show_help
    exit 1
    ;;
esac
