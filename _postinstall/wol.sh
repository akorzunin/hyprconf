#!/usr/bin/env nu
let interface = (nmcli c show | from ssv | get NAME | to text | fzf)
nmcli c show $interface | grep 802-3-ethernet.wake-on-lan
nmcli c modify $interface 802-3-ethernet.wake-on-lan magic

