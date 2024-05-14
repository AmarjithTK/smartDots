#!/bin/bash

choice=$(echo -e "Shutdown\nRestart\nLogout" | rofi -dmenu -p "Choose an action:")

case "$choice" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Restart")
        systemctl reboot
        ;;
    "Logout")
        bspc quit
        ;;
esac

