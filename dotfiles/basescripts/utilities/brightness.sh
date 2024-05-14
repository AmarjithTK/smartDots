#!/bin/bash

# Check if xrandr is installed
if ! command -v xrandr &>/dev/null; then
    exit 1
fi

# Get current brightness value
current_brightness=$(xrandr --verbose | grep -i brightness | awk '{print $2}')

# Set increment value
increment=0.1

# Check if argument provided and set default increment for decrease
if [[ $1 == "decrease" ]]; then
    increment=-$increment
fi

# Calculate new brightness value
new_brightness=$(echo "$current_brightness + $increment" | bc)

# Ensure new_brightness is within valid range (0 to 1)
new_brightness=$(awk -v nb="$new_brightness" 'BEGIN { print (nb < 0) ? 0 : (nb > 1) ? 1 : nb }')

# Apply new brightness using xrandr
xrandr --output $(xrandr | grep ' connected' | awk '{print $1}') --brightness $new_brightness

