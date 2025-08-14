#!/bin/sh
CONFIG_PATH=$(pwd)
touch ./hypr/monitors.conf

cd $HOME/.config/

ln -sf $CONFIG_PATH/hypr
ln -sf $CONFIG_PATH/rofi
ln -sf $CONFIG_PATH/kitty
ln -sf $CONFIG_PATH/waybar
ln -sf $CONFIG_PATH/hyprland_scripts
ln -sf $CONFIG_PATH/dunst
