#!/usr/bin/env bash

# Get pane info for tmux
pane_pid="$1"
pane_cmd="$2"

# Continue only if pane is ssh or has an ssh child process
if [ "$pane_cmd" = "ssh" ]; then
  ssh_pid="$pane_pid"
else
  ssh_pid=$(pgrep -P "$pane_pid" ssh | head -n1)
fi

# Stop if no ssh process was found
[ -n "$ssh_pid" ] || exit 0

# Extract the full command from the pid
read -ra cmd <<< "$(ps -o args= -p "$ssh_pid")"

# Extract the hostname (i suppose is the last element) from the ssh command
host="${cmd[-1]}"

# Strip the user@ if present
host="${host##*@}"

# Print the results
[ -n "$host" ] && printf "@%s" "$host"
