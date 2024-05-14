


# Todo - add window manager independant autostart scripts
# add - wallpaper downloader script that 
#

blueman-applet &
shutdown "2:00" &
sxhkd &
redshifter 3000 .9 &
# nitrogen --restore &
flameshot &
nm-applet &
slstatus &
kdeconnect-cli -l& 
#feh --recursive --bg-fill --randomize ~/.wallpapers &
qbittorrent &


pkill -x sxhkd ; sxhkd -c ~/.config/sxhkd/bspwm-sxhdrc ~/.config/sxhkd/alone-sxhkdrc &
pkill -x polybar ; polybar &
xrandr --output eDP-1 --mode 1368x768 


bash ~/basescripts/utilities/livewall.sh &
bash ~/basescripts/utilities/notifyidle.sh &
bash ~/basescripts/utilities/notifybattery.sh &


