#!/bin/bash

# Path to the sound file you want to play
SOUND_FILE="~/.helpers/musics/low_battery.mp3"

# Battery level threshold (45%)
BATTERY_THRESHOLD=45

# Notification duration in seconds (2 minutes)
NOTIFICATION_DURATION=15

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

    # Get the charging status
    charging_status=$(upower -i $(upower -e | grep BAT) | grep --color=never -E state|xargs|cut -d' ' -f2)

    # Check if the battery level is below the threshold and the battery is not charging
    if [ "$battery_level" -lt "$BATTERY_THRESHOLD" ] && [ "$charging_status" != "charging" ]; then
        # Play the notification sound
        play_notification_sound
    fi

    # Wait for a minute before checking again
    sleep 300
done

