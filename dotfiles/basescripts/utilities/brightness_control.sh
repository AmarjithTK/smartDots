#!/bin/bash

# Set the step value for brightness adjustment
STEP=10  # Adjust step size to 5 for a 0-100 range

# File to store the current brightness
BRIGHTNESS_FILE=~/.helpers/brightness.txt

# Check if the brightness file exists; if not, initialize it with a value of 100 (100%)
if [ ! -f "$BRIGHTNESS_FILE" ]; then
  echo "100" > "$BRIGHTNESS_FILE"
fi

# Get the current brightness from the file
CURRENT_BRIGHTNESS=$(cat "$BRIGHTNESS_FILE")

# Function to apply brightness using ddcutil
apply_ddcutil_brightness() {
  local new_brightness=$1
  local ddc_displays=$(ddcutil detect | grep "Display" | awk '{print $1}' | xargs)

  echo "the new $new_brightness"
  for ddc_display in $ddc_displays; do
    # Set brightness in the range 0-100
    ddcutil set 10 "$new_brightness"
  done
}

# Function to apply brightness using xrandr
apply_xrandr_brightness() {
  local new_brightness=$1
  local xrandr_displays=$(xrandr --query | grep " connected" | awk '{print $1}' | xargs)

  for xrandr_display in $xrandr_displays; do
    # Normalize the brightness value for xrandr (0.0 to 1.0)
    local normalized_brightness=$(echo "scale=2; $new_brightness / 100" | bc)
    echo "normalized_brightness = $normalized_brightness"
    echo "display is $xrandr_display"
    xrandr --output "$xrandr_display" --brightness "$normalized_brightness"
  done
}

# Check for connected displays using ddcutil
if ddcutil detect | grep -q "Display"; then
  DISPLAY_TYPE="ddcutil"
else
  DISPLAY_TYPE="xrandr"
fi

# Handle the command based on the argument
case "$1" in
  increase)
    NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS + $STEP" | bc)
    if (( NEW_BRIGHTNESS > 100 )); then
      NEW_BRIGHTNESS=100
    fi
    # Save the new brightness value to the file
    echo "$NEW_BRIGHTNESS" > "$BRIGHTNESS_FILE"
    ;;

  decrease)
    NEW_BRIGHTNESS=$(echo "$CURRENT_BRIGHTNESS - $STEP" | bc)
    if (( NEW_BRIGHTNESS < 0 )); then
      NEW_BRIGHTNESS=0
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

# Apply brightness based on the detected display type
if [ "$DISPLAY_TYPE" == "ddcutil" ]; then
  apply_ddcutil_brightness "$NEW_BRIGHTNESS"
else
  apply_xrandr_brightness "$NEW_BRIGHTNESS"
fi

