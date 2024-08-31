


# Todo - add window manager independant autostart scripts
# add - wallpaper downloader script that 
#

blueman-applet &
#sxhkd &
#redshifter 3000 .9 &
# nitrogen --restore &
flameshot &
nm-applet &
slstatus &
kdeconnect-cli -l& 
#feh --recursive --bg-fill --randomize ~/.wallpapers &
numlockx &

xfce4-power-manager &

pkill -x sxhkd ; sxhkd -c ~/.config/sxhkd/bspwm-sxhdrc ~/.config/sxhkd/alone-sxhkdrc &
pkill -x polybar ; polybar &


bash ~/basescripts/utilities/livewall.sh &

#bash ~/basescripts/utilities/sfwallpaper.sh > $HOME/output-log 2>&1 &
bash ~/basescripts/utilities/greeterwall.sh &
bash ~/basescripts/utilities/notifyidle.sh &
bash ~/basescripts/utilities/bedtime.sh &


# Load device-specific settings based on hostname
HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == *"home-pc"* ]]; then
  bash ~/basescripts/utilities/volume_regulator.sh &
elif [[ "$HOSTNAME" == *"work-laptop"* ]]; then
  bash ~/basescripts/utilities/notifybattery.sh &
  xrandr --output eDP-1 --mode 1920x1080 & 
  xautolock -time 10 -locker "i3lock" &
else
  echo "No specific configuration for this hostname."
fi

sleep 10
bash ~/basescripts/utilities/sfwallpaper.sh &

