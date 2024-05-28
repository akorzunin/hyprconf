#!/bin/sh
INPUT_DEVICE=logitech-usb-keyboard

COMMAND=$(hyprctl -j devices | jq ".keyboards.[] | select (.name == \"$INPUT_DEVICE\").active_keymap")

case "$COMMAND" in
  '"English (US)"'|'"English"') LAYOUT="en" ;;
  '"Russian"'|'"Ru"') LAYOUT="ru" ;;
  *) LAYOUT="??" ;;
esac

echo $LAYOUT
