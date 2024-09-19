#!/bin/bash

LOGFILE="$HOME/.helpers/displaylog"

# Function to log the current state
log_state() {
    echo "$1" > "$LOGFILE"
}

# Function to check the current state from the log
get_state() {
    if [ -f "$LOGFILE" ]; then
        cat "$LOGFILE"
    else
        echo "unknown"
    fi
}

# Check if HDMI-1 is connected
if xrandr | grep "HDMI-1 connected" > /dev/null; then
    # HDMI-1 is connected
    current_state=$(get_state)

    if [ "$current_state" == "eDP-1 off" ] || [ "$current_state" == "unknown" ]; then
        # If eDP-1 is off or unknown, turn it on and mirror to HDMI-1
        xrandr --output eDP-1 --auto --output HDMI-1 --same-as eDP-1
        log_state "eDP-1 on"
    else
        # If eDP-1 is on, turn it off and display only on HDMI-1
        xrandr --output eDP-1 --off --output HDMI-1 --auto
        log_state "eDP-1 off"
    fi
else
    # HDMI-1 is not connected, ensure eDP-1 is always on
    if [ "$(get_state)" == "eDP-1 off" ]; then
        # If eDP-1 is off, turn it on
        xrandr --output eDP-1 --auto
        log_state "eDP-1 on"
    fi
fi

