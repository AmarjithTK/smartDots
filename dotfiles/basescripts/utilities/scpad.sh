#!/bin/bash

winclass=""
helperfile=""
command=""

# Check the argument and set window class, command, and helper file accordingly
case "$1" in
    keep)
        winclass="$(xdotool search --class firepad)"
        command="firefox --new-instance --new-window https://keep.google.com --class firepad"
        helperfile="$HOME/.helpers/padkeep"
        ;;
    gpt)
        winclass="$(xdotool search --class firepad)"
        command="firefox --new-instance --new-window https://chat.openai.com --class firepad"
        helperfile="$HOME/.helpers/padkeep"
        ;;
    term)
        winclass="$(xdotool search --class padterm)"
        command="kitty --class padterm"
        helperfile="$HOME/.helpers/padterm"
        ;;
    *)
        echo "Invalid parameter. Use 'keep', 'gpt', or 'term'."
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
        wmctrl -i -r "$winclass" -b add,hidden  # Hide the window
    elif [ -f "$helperfile" ]; then
        rm "$helperfile"
        wmctrl -i -r "$winclass" -b remove,hidden  # Show the window
        xdotool windowactivate "$winclass"  # Focus the window
    fi
fi

