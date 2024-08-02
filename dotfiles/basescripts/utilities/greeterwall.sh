#!/bin/bash

# Directory to store wallpapers
WALLPAPER_DIR="/usr/share/backgrounds"
WALLPAPER_FILE="$WALLPAPER_DIR/lightdm_wallpaper.jpg"

# Check if ownership is set correctly
if [[ $(stat -c "%U" $WALLPAPER_DIR) != "$USER" ]]; then
    echo "Setting correct ownership and permissions for $WALLPAPER_DIR"
    sudo chown -R $USER:$USER $WALLPAPER_DIR
    sudo chmod -R 755 $WALLPAPER_DIR
fi

# Fetch a random wallpaper from Unsplash
UNSPLASH_URL="https://picsum.photos/1920/1080"
curl -s -L "$UNSPLASH_URL" -o "$WALLPAPER_FILE"

# Verify if the wallpaper was downloaded
if [[ -f "$WALLPAPER_FILE" ]]; then
    echo "Wallpaper downloaded successfully: $WALLPAPER_FILE"
    # Ensure correct permissions for the wallpaper
    chmod 644 "$WALLPAPER_FILE"
else
    echo "Failed to download wallpaper."
    exit 1
fi

# Set the wallpaper for LightDM Slick Greeter
LIGHTDM_CONFIG="/etc/lightdm/slick-greeter.conf"
TEMP_CONFIG="/tmp/slick-greeter.conf"

# Check if the current wallpaper path is already set to the desired file path
CURRENT_WALLPAPER=$(grep "^background=" "$LIGHTDM_CONFIG" | cut -d'=' -f2)

if [[ "$CURRENT_WALLPAPER" != "$WALLPAPER_FILE" ]]; then
    cp "$LIGHTDM_CONFIG" "$TEMP_CONFIG"
    sed -i "s|^background=.*|background=$WALLPAPER_FILE|" "$TEMP_CONFIG"

    if sudo mv "$TEMP_CONFIG" "$LIGHTDM_CONFIG"; then
        echo "LightDM configuration updated successfully."
        # Restart LightDM to apply the new wallpaper
        if sudo systemctl restart lightdm; then
            echo "LightDM restarted successfully."
        else
            echo "Failed to restart LightDM."
        fi
    else
        echo "Failed to update LightDM configuration."
    fi
else
    echo "Wallpaper is already set to the desired file path. No changes made."
fi

