#!/bin/bash

# Get a list of available virtual environments
venv_list=$(find $HOME -maxdepth 5 -type f -name "activate" | grep "/bin/activate" | sed 's|/bin/activate||' | sed "s|$HOME/||")

# Display a numbered list of virtual environments
echo "Available virtual environments:"
counter=1
for venv in $venv_list; do
    echo "$counter) $venv"
    ((counter++))
done

# Display options menu
echo "$counter) Create a new virtual environment"
echo "$((counter+1))) Quit"

# Ask the user to select an option
read -p "Enter the number of the option: " choice

# Check if the user wants to quit
if [ "$choice" == "$((counter+1))" ]; then
    echo "Quitting..."
    exit 0
fi

# Check if the user wants to create a new virtual environment
if [ "$choice" == "$counter" ]; then
    read -p "Enter a name for the new virtual environment: " new_venv_name
    if [ -z "$new_venv_name" ]; then
        echo "Invalid virtual environment name. Exiting..."
        exit 1
    fi

    # Create the new virtual environment
    python3 -m venv "$HOME/$new_venv_name"
    echo "Created new virtual environment: $new_venv_name"

    # Activate the new virtual environment
    source "$HOME/$new_venv_name/bin/activate"
    echo "Activated virtual environment: $new_venv_name"
    exit 0
fi

# Validate the user's choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -le 0 ] || [ "$choice" -gt "$counter" ]; then
    echo "Invalid choice. Exiting..."
    exit 1
fi

# Get the selected virtual environment
selected_venv=$(echo "$venv_list" | sed -n "${choice}p")

# Activate the selected virtual environment
source "$HOME/$selected_venv/bin/activate"
echo "Activated virtual environment: $selected_venv"
