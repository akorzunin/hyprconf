#!/usr/bin/env bash
# Toggle recording of the default output, not the microphone.
set -euo pipefail
umask 077

state_dir="${XDG_RUNTIME_DIR:?}/system-audio-recording"
mkdir -p "$state_dir"
exec 9>"$state_dir/lock"
flock 9

state="$state_dir/state"
log="$state_dir/ffmpeg.log"

is_recording() {
    [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null &&
        grep -Fzxq -- "$file" "/proc/$pid/cmdline" 2>/dev/null
}

if [[ -f "$state" ]]; then
    { read -r pid; read -r file; } < "$state"
    if is_recording; then
        # SIGTERM lets ffmpeg finalize the file; never kill unrelated recorders.
        kill -TERM "$pid"
        for ((i = 0; i < 100; i++)); do
            if ! is_recording; then
                rm -f "$state"
                notify-send "Audio recording saved" "${file/#"$HOME"/\~}" || true
                exit 0
            fi
            sleep 0.1
        done
        notify-send -u critical "Audio recording is still stopping" "Try again shortly. Log: $log" || true
        exit 1
    fi
    rm -f "$state"
fi

sink=$(pactl get-default-sink)
if [[ -z "$sink" ]]; then
    notify-send -u critical "Cannot record audio" "No default output device." || true
    exit 1
fi

output_dir="$HOME/Music/Recordings"
mkdir -p "$output_dir"
timestamp=$(date +%Y-%m-%d_%H-%M-%S-%N)
file="$output_dir/$timestamp.wav"
# MPRIS title is a hint, not matched to this sink; use PipeWire stream matching if needed.
title=$(timeout 1s playerctl metadata --format '{{title}}' 2>/dev/null || true)
title=${title//\//_}
title=${title//[[:cntrl:]]/_}
# Skip oversized titles to stay below Linux's 255-byte filename limit.
if [[ "$title" == *[![:space:]]* ]] && (( $(printf '%s' "$title" | wc -c) <= 180 )); then
    file="$output_dir/$title - $timestamp.wav"
fi
# The sink is fixed for this recording; restart after switching output devices.
# Close the lock FD in the child so later hotkey presses can stop it.
nohup ffmpeg -hide_banner -loglevel error -nostdin -n \
    -f pulse -i "$sink.monitor" -c:a pcm_s16le -rf64 auto "$file" \
    </dev/null >"$log" 2>&1 9>&- &
pid=$!
printf '%s\n%s\n' "$pid" "$file" > "$state"
sleep 0.5

if ! is_recording; then
    rm -f "$state"
    notify-send -u critical "Audio recording failed" "See $log" || true
    exit 1
fi
notify-send "Audio recording started" "Press Super+Ctrl+R to save.\n${file/#"$HOME"/\~}" || true
