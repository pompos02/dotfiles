#!/usr/bin/env bash
pane_cmd="$1"
pane_pid="$2"
pane_current_path="$3"

if [ "$pane_cmd" != "ssh" ]; then
    tmux new-window
    exit 0
fi

# We are in SSH Logic
hostname=$(~/.config/scripts/tmux-ssh-host.sh "$pane_pid" "$pane_cmd")
host="${hostname#@}"

if [ -n "$host" ]; then
    tmux new-window -c "$pane_current_path" ssh "$host"
else
    # fallback
    tmux new-window -c "$pane_current_path"
fi


