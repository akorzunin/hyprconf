#!/bin/sh

window=$(niri msg -j focused-window) || exec kitty
pid=$(printf '%s' "$window" | jq -r '.pid // empty')
app_id=$(printf '%s' "$window" | jq -r '.app_id // empty')

# Kitty itself keeps its launch directory; its shell has the current one.
if [ "$app_id" = kitty ] && [ -n "$pid" ]; then
    for child in $(pgrep -P "$pid"); do
        read -r comm < "/proc/$child/comm" || continue
        [ "$comm" = kitten ] || { pid=$child; break; }
    done
fi

cwd=$(readlink -f "/proc/$pid/cwd") || exec kitty
[ -d "$cwd" ] || exec kitty
exec kitty --directory "$cwd"
