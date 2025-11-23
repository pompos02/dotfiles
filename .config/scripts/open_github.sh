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
    xdg-open "$url"
else
    echo "This repository is not hosted on GitHub"
fi
