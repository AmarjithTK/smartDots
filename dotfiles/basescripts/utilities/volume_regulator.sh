#!/bin/bash

# Set your preset password here
PRESET_PASSWORD="12349"
# Set the interval for checking the volume (in seconds)
CHECK_INTERVAL=1

# Function to check the current volume
get_volume() {
  amixer get Master | grep -oP '[0-9]+(?=%)' | head -n 1
}

# Function to prompt for password
prompt_password() {
  zenity --password --title="high levels of volume about news ....9"
}

# Function to set the volume
set_volume() {
  amixer set Master "$1%"
}

# Monitor volume function
monitor_volume() {
  current_volume=$(get_volume)
  while true; do
    new_volume=$(get_volume)
    if [ "$current_volume" -le 30 ] && [ "$new_volume" -gt 30 ]; then
      password=$(prompt_password)
      if [ "$password" == "$PRESET_PASSWORD" ]; then
        current_volume=$new_volume
      else
        set_volume $current_volume
        zenity --error --text="Incorrect password. Volume change denied."
      fi
    else
      current_volume=$new_volume
    fi
    sleep $CHECK_INTERVAL
  done
}

# Run the monitor volume function
monitor_volume

