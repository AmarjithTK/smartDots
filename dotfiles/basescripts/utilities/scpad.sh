#!/bin/bash

winclass=""
helperfile=""
focus_command=""

# Check the argument and set window class, command, and helper file accordingly
case "$1" in
    keep)
        winclass="$(xdotool search --class padkeep)"
        command="firefox --new-instance --new-window https://keep.google.com --class padkeep"
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
        # Hide the window using wmctrl
        wmctrl -i -r "$winclass" -b add,hidden
    elif [ -f "$helperfile" ]; then
        rm "$helperfile"
        # Show the window and give focus using wmctrl
        wmctrl -i -r "$winclass" -b remove,hidden
        xdotool windowactivate "$winclass"
    fi
fi

