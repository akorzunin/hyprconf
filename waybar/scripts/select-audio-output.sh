#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} != --picker ]]; then
    # Ignore repeated clicks while the picker is open.
    exec flock --nonblock --close "${XDG_RUNTIME_DIR:?}/waybar-audio-output.lock" \
        kitty --class waybar-audio-output --name waybar-audio-output \
        --title "Audio output" -e "$0" --picker
fi

sinks=$(pactl -f json list sinks) || exit 0
default_sink=$(pactl get-default-sink 2>/dev/null || true)

if ! selected_sink=$(
    printf '%s\n' "$sinks" |
        jq -r --arg default "$default_sink" '
            .[]
            | (if .name == $default then "● " else "  " end)
              + (.description // .name)
              + "\t"
              + .name
        ' |
        fzf --no-multi --no-sort --layout=reverse \
            --prompt "Audio output: " \
            --delimiter=$'\t' --with-nth=1
); then
    exit 0
fi

if [ -n "$selected_sink" ]; then
    pactl set-default-sink "${selected_sink##*$'\t'}"
fi
