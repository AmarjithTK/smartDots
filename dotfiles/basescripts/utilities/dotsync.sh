#!/bin/bash

# Path to the usage log file
log_file="$HOME/.helpers/dotlog.txt"

# Get the current day of the week (0=Sunday, 1=Monday, ..., 6=Saturday)
current_day=$(date +%w)

# Check if today is Sunday (0)
if [ "$current_day" -eq "0" ]; then

    # Get the current date in YYYY-MM-DD format
    current_date=$(date +%Y-%m-%d)

    # Check if the usage log file contains the current date's log
    if grep -q "$current_date" "$log_file"; then
        echo "Dotfile operations have already been performed today."
    else
        # Replace the following line with your actual commands for ~/smartDots
        cd ~/smartDots
        git remote set-url origin git@github.com:starlighter4097/smartDots.git
        git pull origin main
        # Perform dotfile operations
        git add . && git commit -m "Dotfile changes on $(date +%Y-%m-%d)" && git push origin

        echo "Dotfile operations performed successfully."

        # Append the current date to the usage log file
        echo "$current_date: Dotfile operations performed" > "$log_file"
    fi
else
    echo "Today is not Sunday. Dotfile operations will not be performed."
fi
