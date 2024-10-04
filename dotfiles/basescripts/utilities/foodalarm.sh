#!/bin/bash

# Path to the alarm sound file
ALARM_SOUND="$HOME/.helpers/musics/foodalarm.mp3"

# Alarms times
declare -a ALARM_TIMES=("07:10" "07:30" "08:00" "12:00" "12:30" "13:00" "19:00" "19:30" "20:00")

# Function to play alarm and schedule shutdown
play_alarm() {
    # Notify user that the alarm is ringing
    notify-send "Alarm!" "Alarm ringing now for $(date +%H:%M)!"
    
    # Play the alarm sound at full volume
    paplay --volume=1 "$ALARM_SOUND" &
    ALARM_PID=$!  # Get the PID of the paplay process
    sleep 300     # Sleep for 5 minutes (300 seconds)

    # Ask if the user has eaten
    if zenity --question --text="Have you eaten your food?" --title="Food Check"; then
        notify-send "Shutdown Cancelled" "You can continue your activities."
    else
        notify-send "Shutdown Scheduled" "Your system will shut down in 5 minutes."
        (sleep 300; shutdown now) &
    fi

    kill "$ALARM_PID"  # Kill the paplay process after 5 minutes
}

# Infinite loop to check the time
while true; do
    CURRENT_TIME=$(date +%H:%M)

    for ALARM_TIME in "${ALARM_TIMES[@]}"; do
        if [ "$CURRENT_TIME" == "$ALARM_TIME" ]; then
            play_alarm
            # Sleep to avoid multiple triggers within the same minute
            sleep 60
        fi
    done

    # Sleep for a short while before checking again
    sleep 1
done

