#!/bin/bash

winclass=""
helperfile=""

# Check the argument and set window class, command, and helper file accordingly
case "$1" in
    keep)
        winclass="$(xdotool search --class padkeep)"
        command="firefox --new-window https://keep.google.com --class padkeep"
        helperfile="$HOME/.helpers/padkeep"
        ;;
    term)
        winclass="$(xdotool search --class padterm)"
        command="kitty --class padterm"
        helperfile="$HOME/.helpers/padterm"
        ;;
    *)
        echo "Invalid parameter. Use 'keep' or 'term'."
        exit 1
        ;;
esac

# Main logic: hide/show or open new window
if [ -z "$winclass" ]; then
    # No existing window, execute the command
    $command
else
    # Toggle show/hide based on the helper file
    if [ ! -f "$helperfile" ]; then
        touch "$helperfile"
        if [ "$1" = "term" ]; then
            bspc node "$winclass" --flag hidden
        else
            wmctrl -i -r "$winclass" -b add,hidden
        fi
    elif [ -f "$helperfile" ]; then
        rm "$helperfile"
        if [ "$1" = "term" ]; then
            bspc node "$winclass" --flag hidden=off
        else
            wmctrl -i -r "$winclass" -b remove,hidden
        fi
    fi
fi

