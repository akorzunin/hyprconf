#!/bin/sh
# Link only picker configs; do not replace unrelated portal settings.
set -eu
repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
yay --noconfirm --answerdiff=None --answeredit=None xdg-desktop-portal-termfilechooser-hunkyburrito-git
if [ ! -f /usr/share/xdg-desktop-portal/portals/termfilechooser.portal ]; then
    echo 'Install xdg-desktop-portal-termfilechooser-hunkyburrito-git first (see _postinstall/yazi_file_picker.md).' >&2
    exit 1
fi

for file in xdg-desktop-portal/niri-portals.conf \
            xdg-desktop-portal/hyprland-portals.conf \
            xdg-desktop-portal-termfilechooser/config \
            yazi/keymap.toml \
            yazi/plugins/picker-escape.yazi/main.lua; do
    target="$config_home/$file"
    mkdir -p -- "$(dirname -- "$target")"
    if [ "$(readlink -- "$target" || true)" != "$repo/$file" ]; then
        ln -sT --backup=numbered -- "$repo/$file" "$target"
    fi
done
systemctl --user daemon-reload
systemctl --user restart xdg-desktop-portal-termfilechooser.service
systemctl --user restart xdg-desktop-portal.service
printf '%s\n' 'Picker configs linked. Restarted portal services as described in _postinstall/yazi_file_picker.md.'
