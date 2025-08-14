#!/bin/sh
# TODO: find a better way to get keyboard layout
# INPUT_DEVICE=logitech-usb-keyboard
INPUT_DEVICE=keychron-k1-keycool-keyboard

COMMAND=$(hyprctl -j devices | jq ".keyboards.[] | select (.name == \"$INPUT_DEVICE\").active_keymap")

case "$COMMAND" in
  '"English (US)"'|'"English"') LAYOUT="en" ;;
  '"Russian"'|'"Ru"') LAYOUT="ru" ;;
  *) LAYOUT="??" ;;
esac

echo $LAYOUT
