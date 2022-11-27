#!/bin/bash


function baseinstall() {
sudo apt update -y && sudo apt upgrade -y
sudo apt install vim zsh 
}

function dockerinstall(){

    curl -sSL https://get.docker.com | sh
    sudo usermod -aG docker euclid
    sudo apt-get install -y libffi-dev libssl-dev
    sudo apt install -y python3-dev
    sudo apt-get install -y python3 python3-pip
    sudo pip3 install docker-compose
    sudo systemctl enable docker

    echo "dockerinstall done" >> rpiconfigure.log

}


function staticip() {

    sudo echo -e "interface eth0\nstatic ip_address=192.168.1.169\nstatic routers=192.168.1.1\nstatic domain_name_servers=1.1.1.1 8.8.8.8" >> /etc/dhcpcd.conf

}


function setaliases() {

	
	# curl -o raw.github zsh extras ...

	mkdir -p .zshconfig
	curl raw >> .zshconfig/alias1



}


function rsyncdocker(){

rsync -azP ~/codium/docker euclid@euler.local:/home/euclid/docker
rsync -azP ~/codium/rpi leonard@euler.local:/home/leonard/rpi

}

function sshmanger(){

ssh-keygen

ssh-copy-id leonard@euler.local



}








# do while loop to ask repeatedly


## case esac choice to execute all these
