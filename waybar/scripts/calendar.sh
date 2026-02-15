#!/bin/bash
cmd="gnome-calendar"

if pgrep -xf "$cmd" > /dev/null; then
    pkill -f "$cmd"
else
    $cmd
fi
