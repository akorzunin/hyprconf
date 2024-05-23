#!/bin/sh
CONFIG_PATH=$(pwd)

cd $HOME/.config/

ln -sf $CONFIG_PATH/hypr
ln -sf $CONFIG_PATH/rofi
ln -sf $CONFIG_PATH/kitty
ln -sf $CONFIG_PATH/waybar
ln -sf $CONFIG_PATH/hyprland_scripts
