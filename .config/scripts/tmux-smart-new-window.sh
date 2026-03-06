#!/usr/bin/env bash
echo "DEBUG: cmd='$1' pid='$2' path='$3'" >> /tmp/tmux_debug.log
pane_cmd="$1"
pane_pid="$2"
pane_current_path="$3"

if [ "$pane_cmd" != "ssh" ]; then
    tmux new-window -c "$pane_current_path"
    exit 0
fi

# We are in SSH Logic
hostname=$(~/.config/scripts/tmux-ssh-host.sh "$pane_pid" "$pane_cmd")
host="${hostname#@}"
echo $host

if [ -n "$host" ]; then
    tmux new-window -c "$pane_current_path" ssh "$host"
else
    # fallback
    tmux new-window -c "$pane_current_path"
fi


