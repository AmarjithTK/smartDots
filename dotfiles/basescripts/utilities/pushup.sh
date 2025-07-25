#!/bin/bash

# 🔄 Loop forever
while true; do
    # ⏱️ Wait 30 minutes (1800 seconds)
    sleep 1800

    # 🔊 Play a system sound (replace with your preferred .mp3/.wav if needed)
    paplay /usr/share/sounds/freedesktop/stereo/phone-incoming-call.oga &

    # 📢 Show a popup notification
    notify-send "🆙 PUSH-UP TIME!" "Do 10 push-ups & 20 squats. Tiny steps = huge gains 💪"

    # ⏳ Optional: Delay after alert to let sound finish
    sleep 5
done

