#!/usr/bin/env bash
set -euo pipefail

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
        fuzzel --dmenu \
            --prompt "Audio output: " \
            --with-nth 1 \
            --accept-nth 2 \
            --only-match
); then
    exit 0
fi

if [ -n "$selected_sink" ]; then
    pactl set-default-sink "$selected_sink"
fi
