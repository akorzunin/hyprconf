#!/bin/sh
CONFIG_PATH=$(pwd)

cd $HOME/.config/

ln -sf $CONFIG_PATH/hypr
ln -sf $CONFIG_PATH/fuzzel
ln -sf $CONFIG_PATH/kitty
ln -sf $CONFIG_PATH/waybar
ln -sf $CONFIG_PATH/dunst
ln -sf $CONFIG_PATH/niri
touch ./niri/monitors.local.kdl
touch ./niri/startup.local.kdl
