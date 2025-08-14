chsh -s /usr/bin/zsh

mkdir -p ~/.local/bin
mkdir -p ~/Documents
mkdir -p ~/Pictures
mkdir -p ~/Downloads

echo 'PATH=$PATH:~/.local/bin
eval "$(starship init zsh)"
if [[ -o interactive ]]; then
    nu
fi
' > ~/.zshrc

# WRAN: only if not using login manager:
echo 'if [[ "$(tty)" == "/dev/tty1" ]]; then
    ~/.local/bin/hyprland.sh
fi' > ~/.zprofile

echo "#!/usr/bin/env sh

exec Hyprland" > ~/.local/bin/hyprland.sh
chmod +x ~/.local/bin/hyprland.sh
