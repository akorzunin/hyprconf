#!/bin/bash
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# Hold the lock for Kitty's lifetime; repeated clicks cannot create stale writers.
exec flock --nonblock "${XDG_RUNTIME_DIR:?}/waybar-todo.lock" \
    kitty --class waybar-todo --name waybar-todo --title TODO \
    -e nu --no-config-file "$script_dir/todo.nu" ui
