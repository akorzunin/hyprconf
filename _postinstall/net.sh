sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved
sudo systemctl enable --now NetworkManager

# from zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/Snowy-Fluffy/zapret.installer/refs/heads/main/installer.sh)"

# tg-ws-proxy
yay -S tg-ws-proxy
ln -s ~/.local/bin/tg-ws-proxy /usr/sbin/tg-ws-proxy

# hiddify
curl -o ~/.local/bin/hiddify https://github.com/hiddify/hiddify-app/releases/download/v4.1.1/Hiddify-Linux-x64-AppImage.AppImage
chmod +x ~/.local/bin/hiddify

# sshuttle
yay -S sshuttle
sudo sshuttle -r {server_user}@{server_ip} 0/0 --dns
