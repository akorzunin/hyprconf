sudo systemctl disable ly

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I $TERM
EOF

