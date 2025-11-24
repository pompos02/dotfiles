#!/bin/bash
# Kitty theme toggle script
# Switches between dark.conf and light.conf themes

KITTY_CONFIG_DIR="$HOME/.config/kitty"
CURRENT_THEME_LINK="$KITTY_CONFIG_DIR/current-theme.conf"
DARK_THEME="$KITTY_CONFIG_DIR/dark.conf"
LIGHT_THEME="$KITTY_CONFIG_DIR/light.conf"
NVIM_INIT="$HOME/.config/nvim/init.lua"

# Determine current theme by checking what the symlink points to
current_target=$(readlink "$CURRENT_THEME_LINK")

# Toggle to the opposite theme
if [[ "$current_target" == "dark.conf" ]] || [[ "$current_target" == *"/dark.conf" ]]; then
    new_theme="$LIGHT_THEME"
    new_link="light.conf"
    theme_name="Light"
else
    new_theme="$DARK_THEME"
    new_link="dark.conf"
    theme_name="Dark"
fi

# Update the symlink
ln -sf "$new_link" "$CURRENT_THEME_LINK"

# Apply the new theme to all kitty instances
# Using kitten @ set-colors with --all flag to update all windows
kitten @ set-colors --all --configured "$CURRENT_THEME_LINK"

# Toggle Nvim colorscheme in init.lua
if grep -q '^vim\.cmd\.colorscheme("misirlou-lightstrong")' "$NVIM_INIT"; then
    # Light is currently active, switch to dark
    sed -i 's/^vim\.cmd\.colorscheme("misirlou-lightstrong")/-- vim.cmd.colorscheme("misirlou-lightstrong")/; s/^-- vim\.cmd\.colorscheme("misirlou-lb")/vim.cmd.colorscheme("misirlou-lb")/' "$NVIM_INIT"
else
    # Dark is currently active, switch to light
    sed -i 's/^vim\.cmd\.colorscheme("misirlou-lb")/-- vim.cmd.colorscheme("misirlou-lb")/; s/^-- vim\.cmd\.colorscheme("misirlou-lightstrong")/vim.cmd.colorscheme("misirlou-lightstrong")/' "$NVIM_INIT"
fi

# Display a notification (optional, but helpful for user feedback)
# notify-send "Switched to $theme_name theme"

# Exit successfully
exit 0
