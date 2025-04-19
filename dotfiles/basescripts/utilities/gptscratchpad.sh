#!/bin/bash

APP="qutebrowser"
TITLE="GPT-SCRATCH"
URL="https://chat.openai.com"

WIN_WIDTH=1728
WIN_HEIGHT=972





VISIBLE_POS="100,100"

# Get window ID
win_id=$(xdotool search --name "$TITLE" 2>/dev/null | head -n 1)

if [ -n "$win_id" ]; then
    # Check if window is minimized
    is_minimized=$(xprop -id "$win_id" | grep "_NET_WM_STATE" | grep "_NET_WM_STATE_HIDDEN")
    
    if [ -z "$is_minimized" ]; then
        # Window exists and is visible, so minimize it
        xdotool windowminimize "$win_id"
    else
        # Window exists but is minimized, so show and activate it
        xdotool windowactivate "$win_id"
        wmctrl -i -r "$win_id" -b add,above
    fi
else
    # Launch new
    $APP "$URL" -s window.title_format "$TITLE" &
    sleep 2

    for i in {1..10}; do
        win_id=$(xdotool search --name "$TITLE" 2>/dev/null | head -n 1)
        [ -n "$win_id" ] && break
        sleep 0.5
    done

    if [ -n "$win_id" ]; then
        xdotool windowsize "$win_id" $WIN_WIDTH $WIN_HEIGHT
        xdotool windowmove "$win_id" $VISIBLE_POS
        wmctrl -i -r "$win_id" -b add,above
        xdotool windowactivate "$win_id"
    else
        echo "❌ Couldn't launch window"
    fi
fi