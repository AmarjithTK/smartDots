#!bin/bash
nohup bash ~/basescripts/utilities/dotsync.sh 2>&1 &
nohup bash ~/basescripts/utilities/codespace.sh 2>&1 &
bash ~/basescripts/utilities/wallfetch.sh 2>&1 &
