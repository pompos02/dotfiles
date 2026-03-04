#!/usr/bin/env bash
set -euo pipefail

cd "$(tmux run "echo #{pane_start_path}")" || exit
url=$(git remote get-url origin)

if [[ $url == *github.com* ]]; then
    if [[ $url == git@* ]]; then
        url="${url#git@}"
        url="${url/:/\/}"
        url="https://$url"
    fi
else
    echo "This repository is not hosted on GitHub"
    exit 1
fi

if  command -v explorer.exe >/dev/null 2>&1; then
    explorer.exe "$url" >/dev/null 2>&1 &
    return 0
fi

if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url" >/dev/null 2>&1 &
    return 0
fi

echo "No suitable opener found on this system."
return 1
