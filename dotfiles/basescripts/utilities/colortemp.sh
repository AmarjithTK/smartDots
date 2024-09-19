#!/bin/bash

# Check if redshift is installed
if ! command -v redshift &>/dev/null; then
    exit 1
fi

# Location to store the color temperature
temp_file="$HOME/.helpers/colortemp.txt"

# Set default color temperature value
default_temp=4000

# Retrieve the last set temperature from the temp file
if [[ -f "$temp_file" ]]; then
    last_temp=$(cat "$temp_file")
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

# Store the new temperature in the temp file
echo "$new_temp" > "$temp_file"

# Apply brightness using your custom brightness control script
