#!/bin/bash


cd ~/code-ssd && git add . && git commit -m "changes done on $(date "+%F %I:%M %p") " && sleep 11 && git push origin code-ssd-10750H
sleep 10
cd ~ && git add -u && git commit -m "changes done on $(date "+%F %I:%M %p") " && sleep 21 && git push origin dwm-endeavour5
sleep 24
cd ~/dwm && git add -u && git commit -m "changes done on $(date "+%F %I:%M %p") " && sleep 8 && git push origin dwm-endeavour5


crontab -l > ~/cron.txt
(pacman -Qqe && pacman -Qqm) | sort | uniq > ~/pacman.txt
