#!/bin/bash

# Directory containing setup scripts
SETUP_DIR=~/basescripts/configs

# Function to execute selected setup scripts
function choicerunner() {
    # Locate all .setup files and sort alphabetically
    setup_files=($(find "$SETUP_DIR" -type f -name "*.setup" | sort))

    # Print available setup scripts
    echo "Available setup scripts:"
    for ((i=0; i<${#setup_files[@]}; i++)); do
        filename=$(basename "${setup_files[i]}")
        echo "$((i+1))) $filename"
    done
    echo

    # Prompt user to select setup scripts
    read -p "Enter the numbers of the setups you want to perform (separated by whitespace), or 'q' to quit: " -a selected_setups

    # Check if user wants to quit
    if [[ "${selected_setups[@]}" == "q" ]]; then
        echo "Exiting..."
        exit 0
    fi

    # Execute selected setup scripts
    for setup_number in "${selected_setups[@]}"; do
        # Convert input to integer
        if [[ "$setup_number" =~ ^[0-9]+$ ]]; then
            index=$((setup_number - 1))
            if [[ $index -ge 0 && $index -lt ${#setup_files[@]} ]]; then
                setup_file="${setup_files[index]}"
                echo "Executing $setup_file"
                source "$setup_file"
                if [[ $? -ne 0 && ${#selected_setups[@]} -gt 1 ]]; then
                    echo "Error executing $setup_file. Continuing with the next script."
                elif [[ $? -ne 0 && ${#selected_setups[@]} -eq 1 ]]; then
                    echo "Error executing $setup_file. Exiting..."
                    exit 1
                fi
            else
                echo "Invalid choice: $setup_number"
            fi
        else
            echo "Invalid choice: $setup_number"
        fi
    done
}

while true; do
    choicerunner
done

