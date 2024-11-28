#!/bin/bash



# Check if stow is installed
if ! command -v stow &> /dev/null; then sudo dnf install -y stow; fi



# stow dotfiles -t ~/ *

stow -d ~/smartDots -t ~ dotfiles
