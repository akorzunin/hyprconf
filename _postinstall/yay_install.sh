sudo pacman -S --needed base-devel git
cd ~
mkdir -p build
cd build
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# sudo vim /etc/pacman.conf
# [options]
# Color
# ILoveCandy

# enable multilib (for steam)
# sudo vim /etc/pacman.conf
# [multilib]
# Include = /etc/pacman.d/mirrorlist

# yay -Syu
