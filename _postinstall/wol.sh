#!/usr/bin/env nu
# yay -S ethtool

# d - disabled
# g - wol on magic packet

ip a
let interface = (input 'Enter interface name: ')
sudo ethtool $interface | grep "Wake-on"
(input "Set wol to g? [Y]es/^C ")
ethtool -s $interface wol g
sudo ethtool $interface | grep "Wake-on"

