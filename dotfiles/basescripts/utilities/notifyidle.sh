#!/bin/bash

# Path to the sound file you want to play
SOUND_FILE="~/.helpers/musics/idle.mp3"

# Idle time threshold in milliseconds (10 minutes = 600000 milliseconds)
IDLE_TIME_THRESHOLD=600000

# Notification duration in seconds (2 minutes)
NOTIFICATION_DURATION=30

# Function to play the notification sound in a loop for the specified duration
play_notification_sound() {
    end_time=$((SECONDS + NOTIFICATION_DURATION))
    while [ $SECONDS -lt $end_time ]; do
        eval "paplay $SOUND_FILE"
    done
}

# Function to check if any audio playback is running (including browser)
is_audio_playing() {
    # Get the list of active sink inputs (audio streams)
    active_audio=$(pactl list sink-inputs | grep -e 'RUNNING')

    # Check for audio streams coming from popular browsers (e.g., Chrome, Firefox)
    browser_audio=$(pactl list sink-inputs | grep -e 'application.name = "Chrome"' -e 'application.name = "Firefox"')

    # If either variable is not empty, audio is being played
    if [ -n "$active_audio" ] || [ -n "$browser_audio" ]; then
        return 0  # true, audio is playing
    else
        return 1  # false, no audio playing
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

