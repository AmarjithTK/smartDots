#!/bin/bash

# Set the step value for brightness adjustment
STEP=0.05

# File to store the current brightness
BRIGHTNESS_FILE=~/.helpers/brightness.txt

# Get the connected display
CONNECTED_DISPLAY=HDMI-1

# Check if the brightness file exists, otherwise initialize it with a value of 1.0
if [ ! -f "$BRIGHTNESS_FILE" ]; then
  echo "1.0" > "$BRIGHTNESS_FILE"
fi

# Get the current brightness from the file
CURRENT_BRIGHTNESS=$(cat "$BRIGHTNESS_FILE")

# Check if the current brightness is a valid number
#if ! [[ "$CURRENT_BRIGHTNESS" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
 # echo "Error: Invalid brightness value in $BRIGHTNESS_FILE"
  #exit 1
#fi

# Handle the command based on the argument
case "$1" in
  increase)
    NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS + $STEP" | bc)
    if (( $(echo "$NEW_BRIGHTNESS > 1.0" | bc -l) )); then
      NEW_BRIGHTNESS=1.0
    fi
    # Save the new brightness value to the file
    echo "$NEW_BRIGHTNESS" > "$BRIGHTNESS_FILE"
    ;;

  decrease)
    NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS - $STEP" | bc)
    if (( $(echo "$NEW_BRIGHTNESS < 0.1" | bc -l) )); then
      NEW_BRIGHTNESS=0.1
    fi
    # Save the new brightness value to the file
    echo "$NEW_BRIGHTNESS" > "$BRIGHTNESS_FILE"
    ;;

  apply)
    NEW_BRIGHTNESS=$CURRENT_BRIGHTNESS
    ;;

  *)
    echo "Usage: $0 {increase|decrease|apply}"
    exit 1
    ;;
esac

# Apply the brightness value to the connected display
xrandr --output "$CONNECTED_DISPLAY" --brightness "$NEW_BRIGHTNESS"

