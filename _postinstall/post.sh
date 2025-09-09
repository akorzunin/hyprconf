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

