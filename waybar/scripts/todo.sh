#!/bin/bash
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# Close only the previous TODO Kitty instance before replacing it.
pkill -f '^kitty --class waybar-todo --name waybar-todo --title TODO( |$)' || [ "$?" -eq 1 ]
# Wait for shutdown, then hold the lock without passing it to clipboard/editor children.
exec flock --wait 5 --close "${XDG_RUNTIME_DIR:?}/waybar-todo.lock" \
    kitty --class waybar-todo --name waybar-todo --title TODO \
    -e nu --no-config-file "$script_dir/todo.nu" ui
