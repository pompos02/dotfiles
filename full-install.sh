#!/bin/bash
set -e

# Run minimal install first
./install-minimal.sh

# Install GUI packages
sudo pacman -S --needed --noconfirm \
  hyprland waybar hyprpaper hypridle hyprlock \
  kitty dunst brightnessctl pavucontrol playerctl \
  nautilus grim slurp

# Install AUR GUI packages
yay -S --needed --noconfirm \
   zen-browser-bin rofi spotify-launcher obsidian \
  visual-studio-code-bin localsend ttf-jetbrains-mono-nerd \
  vesktop-git gimp miniconda3

# Stow ALL configs
# stow .

echo "Full setup complete! Logout and select Hyprland."
