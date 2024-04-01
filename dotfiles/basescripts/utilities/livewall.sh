#!/bin/bash

# Set the file path for the wallpaper
wallpaper_path="$HOME/.wallpapers/default.jpg"

# Function to check internet connectivity
check_internet() {
    wget -q --spider http://google.com
    return $?  # Returns 0 if internet is available, non-zero otherwise
}

# Check if there is internet connectivity
if check_internet; then
    # If internet is available, download a new wallpaper
    curl -sL -o "$wallpaper_path" "https://source.unsplash.com/1920x1080/?nature,water"
else
    echo "Internet not available. Using existing wallpaper."
fi

# Set the wallpaper using feh
feh --bg-fill "$wallpaper_path"
