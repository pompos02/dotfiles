#!/bin/bash
set -e

# Update system
sudo pacman -Syu --noconfirm

# Install CLI essentials in one go
sudo pacman -S --needed --noconfirm \
  base-devel git stow \
  zsh tmux neovim starship \
  fd ripgrep bat eza fzf zoxide \
  python nodejs npm openssh btop curl wget \
  tar unzip docker man-db lazygit

# Install yay
if ! command -v yay; then
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si
fi

# Change shell to zsh
chsh -s $(which zsh)

# Stow CLI configs
# stow shell tmux nvim scripts

echo "Minimal setup complete! Restart shell."
