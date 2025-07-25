#!/bin/bash

# Path to a loud sound file (change this to any loud local file you have)
SOUND_PATH="/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"

# Function to play sound for 2 seconds at full volume
play_loud_noise() {
    # Set volume to 100%
    pactl set-sink-volume @DEFAULT_SINK@ 100% 2>/dev/null

    # Play sound using ffplay (2 seconds max)
    if command -v ffplay &>/dev/null; then
        ffplay -nodisp -autoexit -t 2 "$SOUND_PATH" >/dev/null 2>&1
    elif command -v paplay &>/dev/null; then
        paplay "$SOUND_PATH" &
        sleep 2 && kill $!
    elif command -v aplay &>/dev/null; then
        aplay "$SOUND_PATH" &
        sleep 2 && kill $!
    else
        echo "❌ No audio player found (ffplay, paplay, or aplay)."
        exit 1
    fi
}

# Main loop
while true; do
    HOUR=$(date +%H)
    MIN=$(date +%M)

    if (( 10#$HOUR > 22 || (10#$HOUR == 22 && 10#$MIN >= 30) )); then
        echo "🚨 It's after 10:30 PM. You should not be using your computer!"
        
        # Loop to annoy
        while true; do
            play_loud_noise
            sleep 15
        done
    fi

    sleep 30
done
