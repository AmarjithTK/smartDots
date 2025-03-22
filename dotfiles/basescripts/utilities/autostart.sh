#!/bin/bash

# Function for BSPWM environment
autostart_bspwm() {
  # Start utilities
  bash ~/basescripts/utilities/sfwallpaper.sh &
  bash ~/basescripts/utilities/foodalarm.sh &

  blueman-applet &
  nm-applet &
  kdeconnect-cli -l & 
  numlockx &

  xfce4-power-manager &

  # Reload sxhkd and polybar
  pkill -x sxhkd ; sxhkd -c ~/.config/sxhkd/bspwm-sxhdrc ~/.config/sxhkd/alone-sxhkdrc &
  pkill -x polybar ; polybar &

  # Start compositor
  picom &

  # Run additional scripts
  bash ~/basescripts/utilities/greeterwall.sh &
  bash ~/basescripts/utilities/bedtime.sh &

  # Load device-specific settings based on hostname
  HOSTNAME=$(hostname)
  if [[ "$HOSTNAME" == *"home-pc"* ]]; then
    xrandr --output eDP-1 --auto --output HDMI-1 --same-as eDP-1
  elif [[ "$HOSTNAME" == *"work-laptop"* ]]; then
    xrandr --output eDP-1 --auto
    bash ~/basescripts/utilities/notifybattery.sh &
    bash ~/basescripts/utilities/grayscale_toggle.sh
  else
    echo "No specific configuration for this hostname."
  fi
}

# Blank function for Plasma environment
autostart_plasma() {
bash ~/basescripts/utilities/foodalarm.sh
bash ~/basescripts/utilities/bedtime.sh
bash ~/basescripts/utilities/notifybattery.sh

  pkill -x sxhkd ; sxhkd -c ~/.config/sxhkd/alone-sxhkdrc &
}

# Main logic: parse the environment argument
if [[ "$1" == "--environment=bspwm" ]]; then
  autostart_bspwm
elif [[ "$1" == "--environment=plasma" ]]; then
  autostart_plasma
else
  echo "Usage: $0 --environment=bspwm|plasma"
  exit 1
fi
