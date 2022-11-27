#!/bin/bash


 baseinstall () {
sudo apt update -y && sudo apt upgrade -y
sudo apt install vim zsh tmux 
sudo apt install usbmount
#sudo echo "export ZPASS=passwordforzip" >> /etc/profile

}

 dockerinstall(){

    # curl -sSL https://get.docker.com | sh
    sudo usermod -aG docker euclid
    sudo apt-get install -y libffi-dev libssl-dev
    sudo apt install -y python3-dev
    # sudo apt-get install -y python3 python3-pip
    sudo pip3 install docker-compose


    # if rust compiler error comes up

    # sudo apt install docker-compose

    #curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    sudo systemctl enable docker

    echo "dockerinstall done" >> rpiconfigure.log

}


 staticip() {

    sudo echo -e "interface eth0\nstatic ip_address=192.168.1.169\nstatic routers=192.168.1.1\nstatic domain_name_servers=1.1.1.1 8.8.8.8" >> /etc/dhcpcd.conf

}


 shellsetup() {

	sudo apt install zsh -y
	# curl -o raw.github zsh extras ...
    sudo chsh -s /bin/zsh 
    curl -fsSL https://raw.githubusercontent.com/AmarjithTK/dotfiles/dwm-endeavour/zsh-extras-config >> ~/.zshrc

	mkdir -p .config/zsh
    curl -fsSL https://raw.githubusercontent.com/AmarjithTK/dotfiles/dwm-endeavour/.zsh_raspberry >> ~/.config/zsh/zsh_alias

    # echo "alias docup=''docup() { docker-compose up -f ~/docker/$1/docker-compose.yml -d ;}; docup'" >> 
	# curl raw >> .zshconfig/alias1



}


 rsyncdocker(){

rsync -azP ~/codium/rpi/docker euclid@euler.local:/home/euclid/docker
rsync -azP ~/codium/rpi/setup euler@192.168.1.7:/home/euler/rpi

}

 sshmanger(){

ssh-keygen

ssh-copy-id leonard@euler.local



}







 choicerunner(){

    echo -e "Enter your choice \n1)base install 2)dockerinstall 3)staticip 4)shellsetup 5)"
    echo -e "\n Press q to quit"   
    read CHOICE
    if [ $CHOICE == 'q' ]; then
        echo "Exiting ....."
        exit 1
    fi

case "$CHOICE" in

  1)
            echo "base install ... \n"
            baseinstall
            ;;

  2)
            echo "dockerinstall \n"
            dockerinstall
            echo -e "\ndone ...................\n"
            ;;
  3)
            echo "staticip ... \n"
            staticip
            echo -e "\ndone ...................\n"
            ;;
   4)
            echo "shellsetup ... \n"
            shellsetup
            echo -e "\ndone ...................\n"
            ;;
   
  *)    
            echo "Wrong choice, exiting ..."
            echo -e "\ndone ...................\n"
            exit 1
            ;;
        
    
esac       
   


}




   




while true
do
    choicerunner
done





# do while loop to ask repeatedly


## case esac choice to execute all these
