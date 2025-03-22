#!/bin/bash

options="Lock\nLogout\nReboot\nShutdown"
selected_option=$(echo -e "$options" | rofi -dmenu -p "Power Menu")

case "$selected_option" in
    Lock)
        # Lock the screen (example: using i3lock)
        i3lock -c 000000
        ;;
    Logout)
        # Log out (example: using i3 exit menu)
        i3-msg exit
        ;;
    Reboot)
        # Reboot the system
        systemctl reboot
        ;;
    Shutdown)
        # Shutdown the system
        systemctl poweroff
        ;;
esac

