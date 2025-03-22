#!/bin/bash

# Create appimages folder in the home directory
APPIMAGES_FOLDER="$HOME/appimages"
mkdir -p "$APPIMAGES_FOLDER"

# Use Zenity to select an action: Install or Delete
ACTION=$(zenity --list --title="AppImage Manager" --text="Select an action:" --column="Action" Install Delete)

# Check if the user selected an action
if [ -z "$ACTION" ]; then
    echo "No action selected. Exiting."
    exit 1
fi

# Install action
if [ "$ACTION" = "Install" ]; then
    # Use Zenity to select an AppImage file
    APPIMAGE=$(zenity --file-selection --file-filter='AppImage files | *.AppImage' --title="Select an AppImage")

    # Check if the user selected a file
    if [ -z "$APPIMAGE" ]; then
        echo "No AppImage selected. Exiting."
        exit 1
    fi

    # Extract the filename without the path
    APPIMAGE_FILENAME=$(basename "$APPIMAGE")

    # Move the AppImage to the appimages folder
    mv "$APPIMAGE" "$APPIMAGES_FOLDER/$APPIMAGE_FILENAME"
    chmod +x "$APPIMAGES_FOLDER/$APPIMAGE_FILENAME"

    # Ask the user for a name for the desktop entry
    DESKTOP_NAME=$(zenity --entry --title="Desktop Entry" --text="Enter a name for the desktop entry:")

    # Create the desktop entry file
    DESKTOP_ENTRY="$HOME/.local/share/applications/$DESKTOP_NAME.desktop"
    echo "[Desktop Entry]
    Name=$DESKTOP_NAME
    Exec=\"$APPIMAGES_FOLDER/$APPIMAGE_FILENAME\" %U
    Icon=$APPIMAGE_FILENAME
    Terminal=false
    Type=Application
    Categories=Utility;" > "$DESKTOP_ENTRY"

    # Make the desktop entry executable
    chmod +x "$DESKTOP_ENTRY"

    echo "Desktop entry created and marked as executable: $DESKTOP_ENTRY"
    exit 0
fi

# Delete action
if [ "$ACTION" = "Delete" ]; then
    # Get a list of installed AppImages
    INSTALLED_APPIMAGES=($(find "$HOME/.local/share/applications" -type f -name "*.desktop" -exec basename {} \; | grep "\.AppImage.desktop$"))

    # Use Zenity to select an installed AppImage for deletion
    SELECTED_APPIMAGE=$(zenity --list --title="Select AppImage to Delete" --text="Select an installed AppImage to delete:" --column="AppImage" "${INSTALLED_APPIMAGES[@]}")

    # Check if the user selected an AppImage
    if [ -z "$SELECTED_APPIMAGE" ]; then
        echo "No AppImage selected for deletion. Exiting."
        exit 1
    fi

    # Delete the selected AppImage and its desktop entry
    rm -f "$HOME/.local/share/applications/$SELECTED_APPIMAGE"
    echo "Desktop entry for $SELECTED_APPIMAGE deleted."

    # Delete the AppImage from the appimages folder
    rm -f "$APPIMAGES_FOLDER/$SELECTED_APPIMAGE"
    echo "AppImage $SELECTED_APPIMAGE deleted from appimages folder."

    exit 0
fi

