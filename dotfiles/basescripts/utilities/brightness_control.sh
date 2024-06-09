#!/bin/bash

# Set the step value for brightness adjustment
STEP=0.1

# Get the connected display
CONNECTED_DISPLAY=$(xrandr -q | grep " connected" | awk '{ print $1 }')

# Get the current brightness of the connected display
CURRENT_BRIGHTNESS=$(xrandr --verbose | grep -i brightness | head -n1 | cut -f2 -d ' ')

# Increase or decrease brightness based on argument
if [ "$1" == "increase" ]; then
  NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS + $STEP" | bc)
  if (( $(echo "$NEW_BRIGHTNESS > 1.0" | bc -l) )); then
    NEW_BRIGHTNESS=1.0
  fi
elif [ "$1" == "decrease" ]; then
  NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS - $STEP" | bc)
  if (( $(echo "$NEW_BRIGHTNESS < 0.0" | bc -l) )); then
    NEW_BRIGHTNESS=0.0
  fi
else
  echo "Usage: $0 {increase|decrease}"
  exit 1
fi

# Apply the new brightness value to the connected display
xrandr --output "$CONNECTED_DISPLAY" --brightness "$NEW_BRIGHTNESS"

