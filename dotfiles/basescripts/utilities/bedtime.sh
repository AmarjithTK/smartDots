#!/bin/bash

# Function to check the current time
check_time() {
  current_time=$(date +%H:%M)
  if [[ "$current_time" == "22:00" ]]; then
    return 0
  else
    return 1
  fi
}

# Loop to check the time
while true; do
  if check_time; then
    # Send a desktop notification for shutdown and bedtime warning
    notify-send -u critical -t 60000 "Shutdown Warning" "The system will shut down in 20 minutes. It's bedtime!"

    # Sleep for 20 minutes
    sleep 1200

    # Shutdown the system
    shutdown now

    # Exit the loop after shutdown command
    break
  fi

  # Sleep for 1 minute before checking the time again
  sleep 60
done

