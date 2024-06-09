#!/bin/bash

# Set your preset password here
PRESET_PASSWORD="1234"

# Function to check the current volume
get_volume() {
  amixer get Master | grep -oP '[0-9]+(?=%)' | head -n 1
}

# Function to prompt for password
prompt_password() {
  zenity --password --title="Authentication Required"
}

# Function to increase volume
increase_volume() {
  amixer set Master "$1%+"
}

# Function to monitor volume changes
monitor_volume() {
  current_volume=$(get_volume)
  while true; do
    new_volume=$(get_volume)
    if [ "$new_volume" -gt "$current_volume" ] && [ "$current_volume" -le 50 ]; then
      password=$(prompt_password)
      if [ "$password" == "$PRESET_PASSWORD" ]; then
        current_volume=$new_volume
      else
        amixer set Master "$current_volume%"
        zenity --error --text="Incorrect password. Volume change denied."
      fi
    else
      current_volume=$new_volume
    fi
    sleep 1
  done
}

# Run the monitor function
monitor_volume
