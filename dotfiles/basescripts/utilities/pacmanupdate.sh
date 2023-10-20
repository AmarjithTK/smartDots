sudo pacman-key --init && \
sudo pacman-key --populate archlinux endeavouros && \
sudo pacman-key --refresh-keys && \
sudo pacman -Syy && \
sudo pacman -Syu --noconfirm

