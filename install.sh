#!/bin/bash
git clone https://github.com/starlighter4097/smartDots.git -b main ~/smartDots 
cd ~/smartDots 
git remote set-url origin git@github.com:starlighter4097/smartDots.git 
bash ./setup.sh 
echo "setting up of stow successful"
bash ~/basescripts/basescripts.sh

# command is :curl -Lo dotsetup https://t.ly/kUbCB | bash dotsetup
