# System Management
alias spy="sudo pacman -Sy"
alias sp="sudo pacman -S --noconfirm"
alias spr="sudo pacman -R"
alias ypy="yay -S"
alias yp="yay -S --noconfirm"
alias basesetup="bash ~/basescripts/basescripts.sh"
alias reflect="sudo reflector --latest 20 --protocol https --save /etc/pacman.d/mirrorlist"


alias copy='xclip -selection clipboard'



# Git Aliases
alias gau="git add -u"

# Development
alias smci="rm -f ~/dwm/config.h && sudo make clean install"
alias vimc="rm -rf ~/.cache/vim/swap"

# KDE Connect

# Miscellaneous
alias sshb="ftp() { ssh admin@$1 -p 2222 ;}; ftp"
alias vi="vim"
alias copyclip='xclip -selection clipboard'


# Define the function
copyn() {
    if [ $# -ne 1 ]; then
        echo "Usage: copyn <number_of_lines>"
        return 1
    fi

    tail -n "$1" | xclip -selection clipboard
}

# Create an alias that calls the function
alias copy='copyn'

alias wifimenu="nmtui"

