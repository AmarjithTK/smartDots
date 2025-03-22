#!/bin/bash

# Function to check and install brightnessctl
install_brightnessctl() {
  if ! command -v brightnessctl &> /dev/null; then
    echo "brightnessctl not found. Installing..."
    if command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm brightnessctl
      if [[ $? -ne 0 ]]; then
        echo "Failed to install brightnessctl. Please check your package manager."
        exit 1
      fi
    else
      echo "Pacman not found. Cannot install brightnessctl."
      exit 1
    fi
  fi
}

# Function to adjust brightness
adjust_brightness() {
  case "$1" in
    increase)
      brightnessctl set +5%
      ;;
    decrease)
      brightnessctl set 5%-
      ;;
    *)
      echo "Usage: $0 increase|decrease"
      exit 1
      ;;
  esac
}

# Main script
install_brightnessctl
adjust_brightness "$1"
