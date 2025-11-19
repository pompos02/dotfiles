#!/bin/bash
set -e

# Update system
sudo pacman -Syu --noconfirm

# Install CLI essentials in one go
sudo pacman -S --needed --noconfirm \
    base-devel stow \
    zsh tmux neovim starship \
    fd ripgrep bat eza fzf zoxide \
    python nodejs npm openssh btop curl wget \
    tar unzip docker man-db lazygit vim

# Install yay
if ! command -v yay; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si
fi

# Change shell to zsh
chsh -s $(which zsh)

# Stow CLI configs
# stow . -t ~ --ignore='hypr|waybar|kitty|dunst|ghostty|walker|minimal-install.sh|full-install.sh|.gitignore|README.md'

echo "Minimal setup complete! Restart shell."
