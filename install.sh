git clone https://github.com/AmarjithTK/smartDots.git -b main ~/smartDots 
cd ~/smartDots 
git remote set-url origin git@github.com:AmarjithTK/smartDots.git 
bash ./setup.sh 
echo "dotfiles copied, now basescripts will be running \n\n"
bash ~/basescripts/basescripts.sh

# command is :curl -Lo d tsetup https://t.ly/kUbCB | bash dotsetup
