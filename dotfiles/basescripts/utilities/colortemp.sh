#!/bin/bash

# Check if redshift is installed
if ! command -v redshift &>/dev/null; then
    exit 1
fi

# Location to store the log
log_dir="$HOME/.config/colortemp"
log_file="$log_dir/log"

# Create log directory if not exist
mkdir -p "$log_dir"

# Set default color temperature value
default_temp=4000

# Retrieve the last set temperature from the log file
if [[ -f "$log_file" ]]; then
    last_temp=$(cat "$log_file")
    current_temp=$last_temp
else
    current_temp=$default_temp
fi

# Set increment value
increment=300

# Check if argument provided and set default increment for decrease
if [[ $1 == "decrease" ]]; then
    increment=-$increment
fi

# Calculate new color temperature
new_temp=$((current_temp + increment))

# Ensure new_temp is within a reasonable range (1000 to 10000)
if (( new_temp < 1000 )); then
    new_temp=1000
elif (( new_temp > 10000 )); then
    new_temp=10000
fi

# Apply new color temperature using redshift
redshift -P -O "$new_temp"

# Store the new temperature in the log file
echo "$new_temp" > "$log_file"

