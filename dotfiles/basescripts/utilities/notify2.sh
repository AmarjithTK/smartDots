#!/bin/bash

# A script to detect user idle time, suppress the alarm if media is playing,
# and trigger a loud, 3-second alarm with a shutdown dialog if truly idle.
#
# Dependencies: xprintidle, pactl, zenity, coreutils (for timeout)

# Configuration
IDLE_TIME_LIMIT=560    # Idle time limit in seconds (560s = 9m 20s)
CHECK_INTERVAL=10      # Check every 10 seconds
ALARM_SOUND="$HOME/.helpers/musics/idle.mp3" # Path to your alarm sound

# Function to get idle time in seconds using xprintidle
get_idle_time() {
    # xprintidle reports in milliseconds, so we divide by 1000
    echo $(($(xprintidle) / 1000))
}

# Function to check if audio or video is playing to suppress the alarm
# This prevents the alarm from triggering while watching a movie or listening to music.
is_media_playing() {
    # Check if any audio sink is active (not corked/suspended)
    # This is a reliable way to detect audio playback from any application.
    if pactl list sink-inputs 2>/dev/null | grep -q -E "State: RUNNING|Corked: no"; then
        return 0 # Media is playing
    fi

    # Fallback check for fullscreen windows, which often implies video
    # This can be useful for players that don't use PulseAudio in a standard way
    local active_win_id=$(xdotool getactivewindow)
    if xprop -id "$active_win_id" _NET_WM_STATE | grep -q _NET_WM_STATE_FULLSCREEN; then
        return 0 # A window is fullscreen
    fi

    return 1 # Media is not playing
}

# Function to trigger the 3-second alarm and show the dialog
trigger_alarm() {
    echo "IDLE DETECTED! Triggering 3-second alarm..."

    # Get all audio sinks (e.g., speakers, headphones)
    local SINKS=$(pactl list short sinks | awk '{print $2}')

    # Set all sinks to 100% volume and unmute them for the alarm
    for SINK in $SINKS; do
        pactl set-sink-volume "$SINK" 100%
        pactl set-sink-mute "$SINK" 0
    done

    # Play the alarm sound for a maximum of 3 seconds in the background
    # `timeout` ensures the command is killed after 3s, regardless of the audio file length.
    timeout 3s paplay "$ALARM_SOUND" &
    local ALARM_PID=$!

    # Show a popup dialog with "Cancel" and "Shutdown" buttons.
    # The script will pause here until the user interacts with the dialog.
    zenity --question \
           --title="Idle Alert" \
           --text="You have been idle for over $(($IDLE_TIME_LIMIT / 60)) minutes.\n\nDo you want to shut down the system?" \
           --ok-label="Shutdown" \
           --cancel-label="Cancel" \
           --default-cancel \
           --width=300

    # Capture the user's choice (0 for OK/Shutdown, 1 for Cancel)
    local USER_CHOICE=$?

    # Stop the alarm sound if the user interacts with the dialog before 3s is up.
    # The '2>/dev/null' suppresses errors if the process has already finished.
    kill $ALARM_PID 2>/dev/null
    wait $ALARM_PID 2>/dev/null # Clean up the background process

    echo "Alarm finished. Setting volume to 50%."
    # Set volume for all sinks to a standard 50% after the alarm
    for SINK in $SINKS; do
        pactl set-sink-volume "$SINK" 50%
    done

    # Action based on user's choice
    if [ $USER_CHOICE -eq 0 ]; then
        echo "User chose to shut down the system. Shutting down now."
        # Use systemctl for modern systems, or 'shutdown now'
        systemctl poweroff
    else
        echo "User canceled the shutdown."
    fi
}

# --- Main Script Loop ---
echo "Idle detection script started. Limit: ${IDLE_TIME_LIMIT}s, Check Interval: ${CHECK_INTERVAL}s"
while :; do
    # Get the current idle time
    idle_time=$(get_idle_time)

    # Uncomment the line below for constant debugging feedback
    # echo "[$(date +%T)] Current idle: ${idle_time}s"

    # Check if the idle time has exceeded the limit
    if (( idle_time >= IDLE_TIME_LIMIT )); then
        # Before triggering alarm, check if media is playing
        if is_media_playing; then
            echo "[$(date +%T)] Idle limit reached, but media is active. Suppressing alarm."
        else
            # If no media is playing, trigger the alarm sequence
            trigger_alarm
            echo "[$(date +%T)] Alarm sequence complete. Resetting idle check."
        fi
        # After an alarm (or suppression), sleep for the full limit to avoid re-triggering immediately
        sleep "$IDLE_TIME_LIMIT"
    else
        # If not idle, sleep for the normal check interval
        sleep "$CHECK_INTERVAL"
    fi
done
