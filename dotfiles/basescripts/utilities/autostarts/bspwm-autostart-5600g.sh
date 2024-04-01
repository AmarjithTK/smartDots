pkill -x sxhkd ; sxhkd -c ~/.config/sxhkd/bspwm-sxhdrc ~/.config/sxhkd/alone-sxhkdrc &
pkill -x polybar ; polybar &
xrandr --output eDP-1 --mode 1368x768 


bash ~/basescripts/utilities/livewall.sh &
