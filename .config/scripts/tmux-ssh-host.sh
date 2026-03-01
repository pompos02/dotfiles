#!/usr/bin/env bash

# Get pane info for tmux
pane_pid="$1"
pane_cmd="$2"
# If tmux says current command is ssh, pane_pid may still be bash.
# Try child ssh first, then fall back to pane_pid.
if [ "$pane_cmd" = "ssh" ]; then
	ssh_pid="$(pgrep -P "$pane_pid" ssh | head -n1)"
	[ -n "$ssh_pid" ] || ssh_pid="$pane_pid"
else
	ssh_pid="$(pgrep -P "$pane_pid" ssh | head -n1)"
fi

# Stop if no ssh process was found
[ -n "$ssh_pid" ] || exit 0

# Extract the full command from the pid
read -ra cmd <<< "$(ps -o args= -p "$ssh_pid")"

# Extract hostname (last arg), strip user@
host="${cmd[-1]}"
host="${host##*@}"

# Avoid showing @-bash / @bash in weird fallback cases
case "$host" in
	bash|-bash|sh|-sh|zsh|-zsh) exit 0 ;;
esac

# Print result
[ -n "$host" ] && printf "@%s" "$host"
