#!/bin/bash

# Set the step value for brightness adjustment
STEP=0.05

# File to store the current brightness
BRIGHTNESS_FILE=~/.helpers/brightness.txt

# Check if the brightness file exists, otherwise initialize it with a value of 1.0
if [ ! -f "$BRIGHTNESS_FILE" ]; then
  echo "1.0" > "$BRIGHTNESS_FILE"
fi

# Get the current brightness from the file
CURRENT_BRIGHTNESS=$(cat "$BRIGHTNESS_FILE")

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

# Get a list of all connected displays, ensuring no extra spaces or newlines
CONNECTED_DISPLAYS=$(xrandr --query | grep " connected" | awk '{print $1}' | xargs)

# Apply the brightness value to all connected displays
for CDISPLAY in $CONNECTED_DISPLAYS; do
  # Trim any unwanted characters from the display name
  CDISPLAY=$(echo "$CDISPLAY" | tr -d '\n\r ')
  if [ -n "$CDISPLAY" ]; then  # Ensure the display variable is not empty
    xrandr --output "$CDISPLAY" --brightness "$NEW_BRIGHTNESS"
  fi
done

