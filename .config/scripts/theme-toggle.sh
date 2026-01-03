#!/usr/bin/env bash
set -euo pipefail

DARK_THEME="CGA (Copy)"
LIGHT_THEME="Tango Light (Copy)"

SETTINGS_PATH="/mnt/c/Users/yiann/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
NVIM_INIT="$HOME/.config/nvim/init.lua"

if [[ ! -f "$SETTINGS_PATH" ]]; then
    echo "settings.json not found at: $SETTINGS_PATH"
    exit 1
fi

if grep -q "\"colorScheme\": \"$DARK_THEME\"" "$SETTINGS_PATH"; then
    #change the colorscheme entry inline
    sed -i "s/\"colorScheme\": \"$DARK_THEME\"/\"colorScheme\": \"$LIGHT_THEME\"/" "$SETTINGS_PATH"
    sed -i "s/\"theme\": \"dark\"/\"theme\": \"light\"/" "$SETTINGS_PATH"
    sed -i "s/vim.opt.background = \"dark\"/vim.opt.background = \"light\"/" "$NVIM_INIT"
    exit 0
fi

if grep -q "\"colorScheme\": \"$LIGHT_THEME\"" "$SETTINGS_PATH"; then
    #change the colorscheme entry inline
    sed -i "s/\"colorScheme\": \"$LIGHT_THEME\"/\"colorScheme\": \"$DARK_THEME\"/" "$SETTINGS_PATH"
    sed -i "s/\"theme\": \"light\"/\"theme\": \"dark\"/" "$SETTINGS_PATH"
    sed -i "s/vim.opt.background = \"light\"/vim.opt.background = \"dark\"/" "$NVIM_INIT"
    exit 0
fi

echo "colorScheme not found in settings.json"
exit 1

