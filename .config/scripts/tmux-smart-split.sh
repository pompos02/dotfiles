#!/usr/bin/env bash

split_type="$1"
pane_cmd="$2"
pane_pid="$3"

if [ "$pane_cmd" != "ssh" ]; then
    tmux split-window -"$split_type"
    exit 0
fi

# We are in SSH Logic
hostname=$(~/.config/scripts/tmux-ssh-host.sh "$pane_pid" "$pane_cmd")
host="${hostname#@}"

if [ -n "$host" ]; then
    tmux split-window -"$split_type"
    tmux send-keys "ssh $host" C-m
else
    # fallback
    tmux split-window -"$direction"
fi


