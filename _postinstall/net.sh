sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved
sudo systemctl enable --now NetworkManager

# from zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Snowy-Fluffy/zapret.installer/refs/heads/main/installer.sh)"

