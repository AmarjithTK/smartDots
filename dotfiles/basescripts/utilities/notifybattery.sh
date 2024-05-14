#!/bin/bash

# Path to the sound file you want to play
SOUND_FILE="~/.helpers/musics/battery_low.mp3"

# Battery level threshold (45%)
BATTERY_THRESHOLD=45

# Notification duration in seconds (2 minutes)
NOTIFICATION_DURATION=60

# Function to play the notification sound in a loop for the specified duration
play_notification_sound() {
    end_time=$((SECONDS + NOTIFICATION_DURATION))
    while [ $SECONDS -lt $end_time ]; do
      eval "paplay $SOUND_FILE"
    done
}

while true; do
    # Get the current battery level
    battery_level=$(upower -i $(upower -e | grep BAT) | grep --color=never -E percentage|xargs|cut -d' ' -f2|sed s/%//)

    # Check if the battery level is below the threshold
    if [ "$battery_level" -lt "$BATTERY_THRESHOLD" ]; then
        # Play the notification sound
        play_notification_sound
    fi

    # Wait for a minute before checking again
    sleep 60
done

