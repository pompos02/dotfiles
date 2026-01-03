#!/usr/bin/env bash
set -euo pipefail

# Get the system theme
THEME_FILE="$HOME/.config/system-theme"
if [[ ! -f "$THEME_FILE" ]]; then
    echo "ERROR: system theme file not found: $THEME_FILE" >&2
    exit 1
fi
SYSTEM_THEME=$(<"$THEME_FILE")

change_nvim_theme(){
    for s in "$XDG_RUNTIME_DIR"/nvim.*; do
        nvim --server "$s" --remote-send ":set background=$1<CR>" 2>/dev/null || true
    done
}

# Windows terminal themes
WINDOWS_DARK_THEME="CGA (Copy)"
WINDOWS_LIGHT_THEME="Tango Light (Copy)"

WINDOWS_TERMINAL_SETTINGS_PATH="/mnt/c/Users/yiann/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
NVIM_INIT="$HOME/.config/nvim/init.lua"
TMUX_SESSIONS_PATH="$HOME/.config/scripts/tmux_sessions.sh"

if [[ "$SYSTEM_THEME" = "dark" ]]; then
    echo "light" > "$THEME_FILE"
    sed -i "s/\"colorScheme\": \"$WINDOWS_DARK_THEME\"/\"colorScheme\": \"$WINDOWS_LIGHT_THEME\"/" "$WINDOWS_TERMINAL_SETTINGS_PATH"
    sed -i "s/\"theme\": \"dark\"/\"theme\": \"light\"/" "$WINDOWS_TERMINAL_SETTINGS_PATH"
    sed -i "s/vim.opt.background = \"dark\"/vim.opt.background = \"light\"/" "$NVIM_INIT"
    sed -i "s/THEME=\"dark\"/THEME=\"light\"/" "$TMUX_SESSIONS_PATH"
    change_nvim_theme light
    exit 0
fi

if [[ "$SYSTEM_THEME" = "light" ]]; then
    echo "dark" > "$THEME_FILE"
    sed -i "s/\"colorScheme\": \"$WINDOWS_LIGHT_THEME\"/\"colorScheme\": \"$WINDOWS_DARK_THEME\"/" "$WINDOWS_TERMINAL_SETTINGS_PATH"
    sed -i "s/\"theme\": \"light\"/\"theme\": \"dark\"/" "$WINDOWS_TERMINAL_SETTINGS_PATH"
    sed -i "s/vim.opt.background = \"light\"/vim.opt.background = \"dark\"/" "$NVIM_INIT"
    sed -i "s/THEME=\"light\"/THEME=\"dark\"/" "$TMUX_SESSIONS_PATH"
    change_nvim_theme dark
    exit 0
fi

echo "colorScheme not found in settings.json"
exit 1
