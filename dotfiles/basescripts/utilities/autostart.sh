
bash ~/basescripts/utilities/sfwallpaper.sh &
bash ~/basescripts/utilities/foodalarm.sh &


# Todo - add window manager independant autostart scripts
# add - wallpaper downloader script that 
#

blueman-applet &
#sxhkd &
#redshifter 3000 .9 &
# nitrogen --restore &
#flameshot &
nm-applet &
#slstatus &
kdeconnect-cli -l& 
#feh --recursive --bg-fill --randomize ~/.wallpapers &
numlockx &

xfce4-power-manager &

pkill -x sxhkd ; sxhkd -c ~/.config/sxhkd/bspwm-sxhdrc ~/.config/sxhkd/alone-sxhkdrc &
pkill -x polybar ; polybar &

picom &

#bash ~/basescripts/utilities/sfwallpaper.sh > $HOME/output-log 2>&1 &
bash ~/basescripts/utilities/greeterwall.sh &
bash ~/basescripts/utilities/bedtime.sh &
bash ~/basescripts/utilities/brightness_control.sh apply



# Load device-specific settings based on hostname
HOSTNAME=$(hostname)
 
if [[ "$HOSTNAME" == *"home-pc"* ]]; then
  bash ~/basescripts/utilities/volume_regulator.sh &
  xrandr --output eDP-1 --auto --output HDMI-1 --same-as eDP-1
elif [[ "$HOSTNAME" == *"work-laptop"* ]]; then

  xrandr --output eDP-1 --off --output HDMI-1 --auto
  bash ~/basescripts/utilities/notifyidle.sh &
  bash ~/basescripts/utilities/notifybattery.sh &
#  xrandr --output eDP-1 --mode 1368x768 & 
  sleep 10
  bash ~/basescripts/utilities/grayscale_toggle.sh
  xautolock -time 30 -locker "i3lock -i $HOME/Pictures/cat_wallpaper.jpg" &
else
  echo "No specific configuration for this hostname."
fi


