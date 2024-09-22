#!/bin/bash

# Path to the sound file you want to play
SOUND_FILE="$HOME/.helpers/musics/idle.mp3"

# Idle time threshold in milliseconds (10 minutes = 600000 milliseconds)
IDLE_TIME_THRESHOLD=10000

# Notification duration in seconds (2 minutes)
NOTIFICATION_DURATION=30

# Function to play the notification sound in a loop for the specified duration
play_notification_sound() {
    end_time=$((SECONDS + NOTIFICATION_DURATION))
    while [ $SECONDS -lt $end_time ]; do
        paplay "$SOUND_FILE"
    done
}

# Function to check if any audio playback is running
is_audio_playing() {
    # Get the list of running audio streams using pactl
    audio_streams=$(pactl list short sink-inputs)

    # Check if there are any active audio streams
    if [ -n "$audio_streams" ]; then
        return 1  # true, audio is playing
    else
        return 0  # false, no audio playing
    fi
}

# Main loop
while true; do
    # Get the current idle time in milliseconds
    idle_time=$(xprintidle)
    echo "Idle time: $idle_time ms"

    # Check if the idle time exceeds the threshold
    if [ "$idle_time" -gt "$IDLE_TIME_THRESHOLD" ]; then
        # Check if audio is being played
        if ! is_audio_playing; then
            # Play the notification sound
            play_notification_sound
        fi
    fi

    # Wait for 30 seconds before checking again
    sleep 1
done

