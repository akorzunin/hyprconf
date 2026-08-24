#!/bin/sh
# Toggle default mic mute with distinct sound + dunst notification.
SND_MUTE=/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga
SND_UNMUTE=/usr/share/sounds/freedesktop/stereo/dialog-warning.oga

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
    paplay "$SND_UNMUTE"
    notify-send -u low -i microphone-sensitivity-high "Microphone" "Unmuted 🎙️"
else
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
    paplay "$SND_MUTE"
    notify-send -u normal -i microphone-sensitivity-muted "Microphone" "Muted 🔇"
fi
