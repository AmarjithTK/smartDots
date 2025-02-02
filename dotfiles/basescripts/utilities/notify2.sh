#!/bin/bash

# Configuration
IDLE_TIME_LIMIT=560    # Idle time limit in seconds (set to 10 minutes: 600)
CHECK_INTERVAL=10 #eck every 10 seconds after the alarm
ALARM_SOUND="$HOME/.helpers/musics/idle.mp3"

# Function to get idle time in seconds
get_idle_time() {
    echo $(($(xprintidle)/1000))
}

# Function to check if audio or video is playing
is_media_playing() {
    # Improved audio detection using cork status
    if pactl list sink-inputs 2>/dev/null | grep -q "Corked: no"; then
        # Check for fullscreen video playback in major browsers
        local BROWSERS=("google-chrome" "brave" "vivaldi" "firefox" "microsoft-edge" "opera")
        for BROWSER in "${BROWSERS[@]}"; do
            if pgrep -x "$BROWSER" > /dev/null; then
                local VIDEO_STATE=$(xdotool search --class "$BROWSER" getwindowgeometry --shell \
                    | grep 'WINDOW=' | cut -d= -f2 \
                    | xargs -I{} xprop -id {} | grep '_NET_WM_STATE(ATOM)')
                
                [[ "$VIDEO_STATE" == *FULLSCREEN* ]] && return 0
            fi
        done
        return 0
    fi
    
    # Check for fullscreen video players
    if pgrep -fl "(vlc|mpv|totem|smplayer|plexmediaplayer)" >/dev/null; then
        local ACTIVE_WIN=$(xdotool getactivewindow getwindowname)
        [[ "$ACTIVE_WIN" == *"vlc"* || "$ACTIVE_WIN" == *"mpv"* ]] && return 0
    fi
    
    return 1
}

# Function to trigger the alarm
trigger_alarm() {
    echo "Triggering alarm after ${IDLE_TIME_LIMIT} seconds idle..."

    # Save the current state of all sinks
    declare -A ORIGINAL_VOLUMES
    declare -A ORIGINAL_MUTES

    # Get all sink names
    SINKS=$(pactl list short sinks | awk '{print $2}')

    # Save original volumes and mute states, then set all sinks to 100% and unmute
    for SINK in $SINKS; do
        ORIGINAL_VOLUMES["$SINK"]=$(pactl list sinks | awk -v sink="$SINK" '$0 ~ "Sink: "sink {getline; getline; print $5}' | tr -d '%')
        ORIGINAL_MUTES["$SINK"]=$(pactl list sinks | awk -v sink="$SINK" '$0 ~ "Sink: "sink {getline; getline; getline; print $2}')
        
        # Set volume to 100% and unmute
        pactl set-sink-volume "$SINK" 100%
        pactl set-sink-mute "$SINK" 0
    done

    # Play the alarm sound in a loop
    while true; do
        paplay "$ALARM_SOUND"
    done &
    ALARM_PID=$!  # Store the PID of the loop process
    
    # Show a popup dialog with "Cancel" and "Shutdown" buttons, with Cancel as default
    zenity --question \
           --title="Idle Alarm" \
           --text="The system has been idle for more than ${IDLE_TIME_LIMIT} seconds.\nDo you want to shut down the system?" \
           --ok-label="Shutdown" \
           --cancel-label="Cancel" \
           --default-cancel
    
    # Capture the user's choice
    USER_CHOICE=$?
    
    # Kill the alarm sound loop after the user interacts with the dialog
    kill $ALARM_PID 2>/dev/null
    
    # Restore all sinks to 50% of their original volume
    for SINK in $SINKS; do
        ORIGINAL_VOLUME=${ORIGINAL_VOLUMES["$SINK"]}
        NEW_VOLUME=$((ORIGINAL_VOLUME / 2)) # 50% of the original volume
        pactl set-sink-volume "$SINK" "${NEW_VOLUME}%"
    done
    
    # Check the user's choice
    if [ $USER_CHOICE -eq 0 ]; then
        echo "User chose to shut down the system."
        shutdown now
    else
        echo "User canceled the shutdown."
    fi
}

# Main loop
while :; do
    idle_time=$(get_idle_time)
    
    echo "[$(date +%T)] Current idle: ${idle_time}s"
    
    if (( idle_time >= IDLE_TIME_LIMIT )); then
        if is_media_playing; then
            echo "[$(date +%T)] Media active - alarm suppressed"
        else
            trigger_alarm
            echo "[$(date +%T)] Activity resumed"
        fi
    fi
    
    sleep "$CHECK_INTERVAL"
done

