#!/bin/sh

window=$(niri msg -j focused-window) || exec kitty
app_id=$(printf '%s' "$window" | jq -r '.app_id // empty')

case "$app_id" in
kitty)
    pid=$(printf '%s' "$window" | jq -r '.pid // empty')
    for child in $(pgrep -P "$pid"); do
        read -r comm < "/proc/$child/comm" || continue
        [ "$comm" = kitten ] || { pid=$child; break; }
    done
    tpgid=$(ps -o tpgid= -p "$pid" | tr -d ' ')
    [ "$tpgid" -gt 0 ] 2>/dev/null && pid=$tpgid
    cwd=$(readlink -f "/proc/$pid/cwd")
    ;;
code)
    workspace=$(printf '%s' "$window" | jq -r '.title // empty')
    workspace=${workspace% - Visual Studio Code}
    workspace=${workspace##* - }
    # ponytail: first name match under $HOME; add a VS Code API if duplicates matter.
    cwd=$(find "$HOME" -type d -name "$workspace" -print -quit 2>/dev/null)
    ;;
*) exec kitty ;;
esac

[ -d "$cwd" ] || exec kitty
exec kitty --directory "$cwd"
