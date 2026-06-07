#!/bin/sh
# smartDots CLI Toolkit — POSIX-compatible
# Source from shell config:
#   . "$HOME/.smartdots/smartdots.sh"
#
# Provides:
#   - 60+ aliases for flutter, git, npm, docker, system
#   - helper command to list/search aliases

SMARTDOTS="${SMARTDOTS_HOME:-$HOME/.smartdots}"
REGISTRY="$SMARTDOTS/registry.txt"

# ─── Load aliases from registry ─────────────────────────────────
if [ -f "$REGISTRY" ]; then
    while IFS='|' read -r category alias_name command; do
        # Skip comments and empty lines
        case "$category" in
            ''|\#*) continue ;;
        esac
        # Skip if alias already exists (user override)
        alias "$alias_name"="$command" 2>/dev/null || true
    done < "$REGISTRY"
fi

# ─── helper command ─────────────────────────────────────────────
helper() {
    _reg="$REGISTRY"
    _filter="$1"

    if [ ! -f "$_reg" ]; then
        echo "smartDots registry not found at $_reg"
        echo "Re-run: bash <(curl -sL https://raw.githubusercontent.com/AmarjithTK/smartDots/main3/cli-toolkit/install.sh)"
        return 1
    fi

    if [ -z "$_filter" ]; then
        # Show all aliases grouped by category
        awk -F'|' '
        /^[a-z]/ {
            if ($1 != prev) {
                title = toupper(substr($1,1,1)) substr($1,2)
                print "\n=== " title " ==="
                prev = $1
            }
            printf "  %-12s %s\n", $2, $3
        }' "$_reg"
    else
        # Filter by category or keyword search
        awk -F'|' -v f="$_filter" '
        /^[a-z]/ && tolower($0) ~ tolower(f) {
            if ($1 != prev) {
                title = toupper(substr($1,1,1)) substr($1,2)
                print "\n=== " title " ==="
                prev = $1
            }
            printf "  %-12s %s\n", $2, $3
        }' "$_reg"
    fi
}
