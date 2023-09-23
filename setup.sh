#!/bin/bash




# Check if stow is installed
if ! pacman -Q stow &> /dev/null; then
    echo "Stow is not installed. Installing..."
    sudo pacman -S stow --noconfirm
    echo "Stow has been installed."
else
    echo "Stow is already installed."
fi


# stow dotfiles -t ~/ *

stow -d ~/smartDots -t ~ dotfiles
