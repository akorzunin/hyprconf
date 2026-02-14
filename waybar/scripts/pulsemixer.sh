#!/bin/bash
cmd="kitty --name kitty-pulsemixer --class kitty-pulsemixer -e pulsemixer"

if pgrep -xf "$cmd" > /dev/null; then
    pkill -f "$cmd"
else
    $cmd
fi
