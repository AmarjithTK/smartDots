#!/bin/bash

# Path to the sound file you want to play
SOUND_FILE="~/.helpers/musics/idle.mp3"

# Idle time threshold in milliseconds (10 minutes = 600000 milliseconds)
IDLE_TIME_THRESHOLD=1800000

# Notification duration in seconds (2 minutes)
NOTIFICATION_DURATION=30

# Function to play the notification sound in a loop for the specified duration
play_notification_sound() {
    end_time=$((SECONDS + NOTIFICATION_DURATION))
    while [ $SECONDS -lt $end_time ]; do
        eval "paplay $SOUND_FILE"
    done
}
is_audio_playing() {
    if pactl list sink-inputs | grep -q "Corked: no" && pactl list sink-inputs | grep -q "Mute: no"; then
        return 0  # True
    else
        return 1 # False
    fi
}
while true; do
    # Get the current idle time in milliseconds
    idle_time=$(xprintidle)
    echo $idle_time

    # Check if the idle time exceeds the threshold
    if [ "$idle_time" -gt "$IDLE_TIME_THRESHOLD" ]; then
        # Check if audio or video is being played
        if ! is_audio_playing; then
            # Play the notification sound
            play_notification_sound
        fi
    fi

    # Wait for a minute before checking again
    sleep 30
done

