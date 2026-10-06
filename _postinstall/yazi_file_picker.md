# Yazi as the file picker (Arch, Niri)

Uses the [hunkyburrito portal backend](https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser)
with its packaged Yazi wrapper and Kitty. Only portal-aware applications use it;
this does not change the default file manager or every application's native dialog.

## Install

Run as your normal desktop user, not root. Install `yay` first if needed
(see `yay_install.sh`). Review the AUR build when prompted.

```sh
sudo pacman -S --needed base-devel git kitty yazi xdg-desktop-portal xdg-desktop-portal-gtk
yay -S --needed xdg-desktop-portal-termfilechooser-hunkyburrito-git

# Keep Niri's backend for screen sharing:
sudo pacman -S --needed xdg-desktop-portal-gnome

# Shared Yazi settings (Git status, chooser-only Esc and double-click):
sh /path/to/dotfiles/install.sh

cd /path/to/hyprconf
sh _postinstall/yazi_file_picker.sh
systemctl --user daemon-reload
systemctl --user restart xdg-desktop-portal-termfilechooser.service
systemctl --user restart xdg-desktop-portal.service
```

Restarting portals can interrupt active screen sharing. Logging out/in instead
also applies the settings. Fully restart the browser/application afterward.

The linker can be rerun, respects `XDG_CONFIG_HOME`, and backs up existing files
as `filename.~1~`, etc. Keep this checkout in place: installed configs are symlinks.
Yazi settings now live in the separate dotfiles repo (`dot_config/yazi`), shared
by normal Yazi and chooser mode. Run its setup when migrating old Hyprconf Yazi
symlinks; this linker no longer creates or overwrites them.
It is separate from `install.sh` so the backend must be installed before opting in.
The AUR package tracks upstream Git; these steps reproduce the setup, not a pinned build.

## Configuration

- `xdg-desktop-portal-termfilechooser/config`: packaged `yazi-wrapper.sh`, Kitty,
  and the application's suggested open/save location (home when unspecified).
- `xdg-desktop-portal/niri-portals.conf`: GNOME/GTK defaults, GTK access and
  notifications, GNOME Keyring secrets; only FileChooser switches to Yazi.

Desktop-specific portal configs preserve screen-sharing backends. Portal configs
are not merged: keep the default/interface entries when customizing these files.

## Niri picker window

The picker launches Kitty with the dedicated app ID `yazi-file-picker`.
The rule in `niri/config.kdl` opens only that app ID floating, centered (Niri's
default for new floating windows), at 50% width and 50% height.
Normal Kitty/Yazi windows are unaffected. Use this repo's Niri config (linked
by `install.sh`), or copy its `yazi-file-picker` window rule into your config.
After changing the picker command, restart
`xdg-desktop-portal-termfilechooser.service`; Niri reloads its config automatically.

## Browsers and selection

In Firefox / Zen, open `about:config` and set
`widget.use-xdg-desktop-portal.file-picker` to **1**, then restart the browser.
For GTK applications that bypass portals, try launching that app with
`GTK_USE_PORTAL=1 application` (not a global environment setting).

Test an upload and Save As from your browser:

- Open: highlight a file and press Enter; use Space to select multiple files.
- Directory: enter the desired directory and press `q` to accept it.
- Cancel: press **Esc** in the file list, or `Q`. Esc closes only chooser-mode
  Yazi (`--chooser-file`), without accepting the current directory. Normal Yazi
  retains its usual Esc behavior. Prompts/help retain their own Esc bindings;
  dismiss them first, then press Esc in the file list to close the picker.
  This uses dotfiles' `dot_config/yazi/keymap.toml` and
  `dot_config/yazi/plugins/picker-escape.yazi/main.lua`.
- Double-click: submit a file in chooser mode only (dotfiles' `init.lua`).
- Save: the wrapper can create a placeholder with instructions; navigate/rename
  it as needed, then select it with Enter to return the destination to the app.

## Troubleshooting

If Kitty flashes and disappears, check `TERMCMD` quoting. The backend expands
its value before the wrapper parses it again. Use
`env=TERMCMD='kitty --class yazi-file-picker --title "Yazi file picker"'` with both layers of quotes.
Without the outer single quotes, Kitty treats `file` as the executable instead
of starting Yazi; the portal then reports a missing selection file and
`Operation not permitted`. Restart the termfilechooser service after changes.

```sh
systemctl --user status xdg-desktop-portal{,-termfilechooser}.service
journalctl --user -b -u xdg-desktop-portal -u xdg-desktop-portal-termfilechooser
systemctl --user show-environment | grep XDG_CURRENT_DESKTOP
```

The service environment should identify `niri`. If it is stale,
log out/in. Check for higher-priority custom portal configuration if the old
picker persists. Non-portal dialogs cannot be replaced by this backend.

## Undo

Remove the two portal symlinks created by the linker from `~/.config` (or your
`XDG_CONFIG_HOME`), restore any numbered backups, and restart
`xdg-desktop-portal.service`. Without overrides, the system desktop defaults apply.
Reset the browser preference if desired. The backend package may remain installed.
