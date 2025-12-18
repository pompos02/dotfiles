#!/bin/bash

DIRS=(
    "$HOME/projects"
    "$HOME"
    "$HOME/projects/personal"
    "$HOME/projects/opensource"
    "/mnt/c/Users/yiann"
)

# State file that stores the last session's directory so it can be prioritized next run.
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/tmux/last_session"
mkdir -p "$(dirname "$STATE_FILE")"

# Gather one-level-deep, non-hidden directories from each root in DIRS.
list_dirs() {
    for root in "${DIRS[@]}"; do
        [[ -d $root ]] || continue
        for d in "$root"/*; do
            [[ -d $d ]] || continue
            [[ $(basename "$d") == .* ]] && continue
            printf '%s\n' "$d"
        done
    done
}

# Read previous session directory if the state file exists.
prev=""
[[ -r $STATE_FILE ]] && prev="$(<"$STATE_FILE")"

# Build the directory list shown to fzf.
all_dirs="$(list_dirs)"

if [[ -n $prev ]]; then
    # Place the previous session directory at the top (if still present).
    final_list="$(printf '%s\n' "$prev" "$(printf '%s\n' "$all_dirs" | grep -Fxv "$prev")")"
else
    final_list="$all_dirs"
fi

# Use the provided arg if present, otherwise open fzf-tmux for selection.
selected=$(echo "$final_list" | fzf\
    --border=rounded --info=right \
    --color=hl:#87CEEB:reverse:bold,hl+:#87CEEB:reverse:bold \
    --color=info:white \
    --color=border:white,list-border:white,preview-border:white,input-border:white,header-border:white,footer-border:white \
    --color=pointer:white)
[[ -z $selected ]] && exit 0
selected="${selected%/}"

# tmux session names cannot contain dots reliably; replace with underscores.
name="$(basename "$selected" | tr . _)"

# Create the session if missing, with its working directory set to the selected path.
tmux has-session -t "$name" 2>/dev/null || tmux new-session -ds "$name" -c "$selected"

# Persist the current session directory so it becomes "previous" on the next run.
current_name="$(tmux display-message -p '#S')"
if [[ $current_name != "$name" ]]; then
    tmux display-message -p '#{session_path}' > "$STATE_FILE"
fi

# Switch to the selected session inside the current tmux client.
tmux switch-client -t "$name"
