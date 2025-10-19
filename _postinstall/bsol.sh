#!/bin/bash
mkdir -p ~/build
cd ~/build/
git clone https://github.com/harishnkr/bsol.git
cd bsol
sudo cp -r bsol/ /boot/grub/themes/bsol

# sudo nvim /etc/default/grub
#
# GRUB_DEFAULT=saved
# GRUB_TIMEOUT=1
# GRUB_THEME="/boot/grub/themes/bsol/theme.txt"
# GRUB_SAVEDEFAULT=true
# GRUB_DISABLE_OS_PROBER=false

# sudo nvim /boot/grub/themes/bsol/theme.txt
#
# terminal-font: "Victor Mono Regular 16"
#
# sudo grub-mkconfig -o /boot/grub/grub.cfg

