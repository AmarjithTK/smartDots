#!/bin/bash

# Path to sound file (choose any short beep or tone you like)
SOUND_FILE="/usr/share/sounds/freedesktop/stereo/complete.oga"

# Save current volume
ORIG_VOL=$(amixer get Master | grep -oP '\[\d+%\]' | head -1)

while true; do
    # Set volume to 50%

    # Play the sound (plays for 1s)
    paplay "$SOUND_FILE" &

    # Let it ring for 1 second, then stop it
    sleep 1
    pkill paplay

    # Restore original volume

    # Wait 5 minutes
    sleep 180
done

