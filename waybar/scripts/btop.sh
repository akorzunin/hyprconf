#!/bin/bash
cmd="kitty --name kitty-btop --class kitty-btop -e btop"

if pgrep -xf "$cmd" > /dev/null; then
    pkill -f "$cmd"
else
    $cmd
fi
