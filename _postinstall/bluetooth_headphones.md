# Bluetooth headphones on Arch Linux

## Install and start Bluetooth/audio services

```sh
sudo pacman -S --needed bluez bluez-utils pipewire pipewire-pulse wireplumber
sudo systemctl enable --now bluetooth
bluetoothctl power on
```

PipeWire and WirePlumber normally start with the desktop session. Verify them with:

```sh
systemctl --user is-active pipewire pipewire-pulse wireplumber
```

## Pair the headphones

Put the headphones in pairing mode, then scan:

```sh
bluetoothctl --timeout 20 scan on
bluetoothctl devices
```

Copy the address shown next to the headphone name and use it below. For the HD 450BT used here, it was `00:1B:66:10:E1:5C`.

```sh
MAC=00:1B:66:10:E1:5C
bluetoothctl --agent NoInputNoOutput pair "$MAC"
bluetoothctl trust "$MAC"
bluetoothctl connect "$MAC"
```

`trust` allows automatic reconnection after login or after the headphones are switched on.

## Select the audio output

```sh
wpctl status
```

Find the numeric sink ID beside the headphones under `Sinks`, then set it as the default. Sink IDs can change between sessions, so do not reuse the example ID blindly.

```sh
SINK_ID=127  # replace with the ID from wpctl status
wpctl set-default "$SINK_ID"
wpctl set-mute "$SINK_ID" 0
wpctl set-volume "$SINK_ID" 0.60
```

Verify the connection and selected sink:

```sh
bluetoothctl info "$MAC" | grep -E '^\s*(Name|Paired|Bonded|Trusted|Connected):'
wpctl status
```
