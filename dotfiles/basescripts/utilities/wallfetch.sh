#!/bin/bash

# Directory to store wallpapers and log
WALLPAPER_DIR="$HOME/.wallpapers"
LOG_FILE="~/.helpers/wallpaper-log.txt"

# Create the directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Get today's date in dd-mm-yy format
TODAYS_DATE=$(date +%d-%m-%y)

# Check if wallpapers were already downloaded today
if grep -q "$TODAYS_DATE" "$LOG_FILE"; then
    echo "Wallpaper was already downloaded today."
    exit
fi

# Download a new wallpaper and save it in the wallpapers directory
curl -sLo "$WALLPAPER_DIR/$TODAYS_DATE-wallpaper.jpg" "https://source.unsplash.com/random/1920x1080"

# Update the log file with today's date
echo "$TODAYS_DATE" > "$LOG_FILE"

# Get the number of image files (jpg, png, etc.) in the directory
num_images=$(find "$WALLPAPER_DIR" -type f \( -iname \*.jpg -o -iname \*.png \) | wc -l)

# If there are more than 5 images, remove randomly to have only 2 images
if [ "$num_images" -gt 5 ]; then
    num_to_remove=$((num_images - 2))
    find "$WALLPAPER_DIR" -type f \( -iname \*.jpg -o -iname \*.png \) | shuf -n "$num_to_remove" | xargs -I {} rm "{}"
fi

echo "New wallpaper downloaded, logged, and old wallpapers cleaned."

