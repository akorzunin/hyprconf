#!/usr/bin/env bash

sudo sed -i 's/^#Color/Color/' /etc/pacman.conf

# TODO: Add ILoveCandy should always be in [options] section

# if grep -q "^ILoveCandy" /etc/pacman.conf; then
#     echo "✓ ILoveCandy is already enabled"
# else
#     # Add ILoveCandy option if not found
#     sudo echo "ILoveCandy" | sudo tee -a /etc/pacman.conf
#     echo "✓ ILoveCandy added"
# fi
