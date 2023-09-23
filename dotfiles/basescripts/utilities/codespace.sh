#!/bin/bash

# Path to the usage log file
log_file="$HOME/.helpers/codespace-log.txt"

# Get the current time in 24-hour format
current_time=$(date +%H%M)

# Loop until it's 5 PM (1700 in 24-hour format)
while [ "$current_time" -lt "1700" ]; do
    echo "Waiting until 5 PM..."
    sleep 60 # Wait for 1 minute before checking again
    current_time=$(date +%H%M) # Update current time
done

# Get the current date in YYYY-MM-DD format
current_date=$(date +%Y-%m-%d)

# Check if the usage log file contains the current date's log
if grep -q "$current_date" "$log_file"; then
    echo "Git operations have already been performed today."
else

    # Check if the Git repository exists, and if not, initialize it and checkout to "main"
    if [ ! -d "$HOME/codespace/.git" ]; then
        cd ~/codespace
        git init
        git remote add origin git@github.com:AmarjithTK/codespace.git
        git checkout -b main
    else
        cd ~/codespace
        git remote set-url origin git@github.com:AmarjithTK/codespace.git
        # git pull origin main
    fi

    # cd ~/codespace
    # git remote set-url origin git@github.com:AmarjithTK/codespace.git
    git pull origin main
    # Perform git operations
    git add .
    git commit -m "Changes till $(date +%Y-%m-%d) $(date +%H:%M:%S)"
    git push origin main
    echo "Git operations performed successfully."

    # Append the current date to the usage log file
    echo "$current_date: Git operations performed" > "$log_file"
fi
