#!/usr/bin/env bash

# Get pane info for tmux
pane_pid="$1"
pane_cmd="$2"

# Continue only if the command is ssh
[ "$pane_cmd" = "ssh" ] || exit 0

# Find ssh child process for the hostname extraction
ssh_pid=$(pgrep -P "$pane_pid" | head -n1)
[ -n "$ssh_pid" ] || exit 0

# Extract the full command from the pid
read -ra cmd <<< "$(ps -o args= -p "$ssh_pid")"

# Extract the hostname (i suppose is the last element) from the ssh command
host="${cmd[-1]}"

# Strip the user@ if present
host="${host##*@}"

# Print the resutls
[ -n "$host" ] && printf "@%s" "$host"
