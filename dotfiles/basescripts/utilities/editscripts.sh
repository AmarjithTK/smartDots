#!/bin/bash

# Define the menu options
options="Rofi Config\nSxhkd Config\nKitty Config\n.zshrc\nEdit ~/basescripts\nEdit ~/bin"
selected_option=$(echo -e "$options" | rofi -dmenu -p "Edit Configs")

# Define the paths to the config files and directories
rofi_config="$HOME/.config/rofi/config"
sxhkd_config="$HOME/.config/sxhkd/sxhkdrc"
kitty_config="$HOME/.config/kitty/kitty.conf"
zshrc="$HOME/.zshrc"
basescripts_dir="$HOME/basescripts"
bin_dir="$HOME/bin"

# Determine which option was selected and open the appropriate file or directory
case "$selected_option" in
    "Rofi Config")
        vim "$rofi_config"
        ;;
    "Sxhkd Config")
        vim "$sxhkd_config"
        ;;
    "Kitty Config")
        vim "$kitty_config"
        ;;
    ".zshrc")
        vim "$zshrc"
        ;;
    "Edit ~/basescripts")
        selected_script=$(ls "$basescripts_dir" | rofi -dmenu -p "Choose a script to edit")
        if [ -n "$selected_script" ]; then
            vim "$basescripts_dir/$selected_script"
        fi
        ;;
    "Edit ~/bin")
        selected_script=$(ls "$bin_dir" | rofi -dmenu -p "Choose a script to edit")
        if [ -n "$selected_script" ]; then
            vim "$bin_dir/$selected_script"
        fi
        ;;
    *)
        echo "No option selected."
        ;;
esac

