#!/usr/bin/env bash
set -euo pipefail

if ! selection=$(cliphist list | awk -F '\t' '
    $2 ~ /^\[\[ binary data .* [0-9]+x[0-9]+ \]\]$/ {
        label = $2
        sub(/^\[\[ binary data /, "", label)
        sub(/ \]\]$/, "", label)
        print $1 "\t" label
    }
' | fzf \
    --layout=reverse \
    --delimiter=$'\t' --with-nth=2.. \
    --prompt='Images > ' \
    --header='Enter: copy · Esc: cancel' \
    --with-shell='bash -c' \
    --preview-window=right:70% \
    --preview='
        tmp=$(mktemp) || exit
        trap "rm -f -- \"$tmp\"" EXIT
        printf "%s\n" {} | cliphist decode > "$tmp" || exit
        /usr/share/fzf/fzf-preview.sh "$tmp"
    '); then
    exit 0
fi

# Decode before invoking wl-copy so failures do not clear the clipboard.
tmp=$(mktemp)
trap 'rm -f -- "$tmp"' EXIT
printf '%s\n' "$selection" | cliphist decode > "$tmp"
# The background clipboard provider must not keep Kitty's terminal open.
wl-copy < "$tmp" >/dev/null 2>&1
