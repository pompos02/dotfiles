#!/bin/bash

DIRS=(
    "$HOME/projects"
    "$HOME"
    "$HOME/projects/personal"
    "$HOME/projects/opensource"
    "/home"
    # "/mnt/c/Users/yiann"
)

THEME="light"

# Find the most recently attached tmux session and its path (if any).
prev_session="$(tmux list-sessions -F '#{session_last_attached} #{session_name}' 2>/dev/null | sort -nr | sed -n '2p' | cut -d' ' -f2-)"
prev=""
if [[ -n $prev_session ]]; then
    prev="$(tmux display-message -p -t "$prev_session" '#{session_path}' 2>/dev/null)"
    [[ -d $prev ]] || prev=""
fi

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

# Build the directory list shown to fzf.
all_dirs="$(list_dirs)"

if [[ -n $prev ]]; then
    # Place the previous session directory at the top (if still present).
    final_list="$(printf '%s\n' "$prev" "$(printf '%s\n' "$all_dirs" | grep -Fxv "$prev")")"
else
    final_list="$all_dirs"
fi

if [[ "$THEME" = "dark" ]]; then
    selected=$(
        echo "$final_list" | fzf \
            --border=rounded --info=right \
            --color=hl:#A5D6FF:reverse:bold,hl+:#79C0FF:reverse:bold \
            --color=info:white \
            --color=border:white,list-border:white,preview-border:white,input-border:white,header-border:white,footer-border:white \
            --color=fg+:#FFFFFF \
            --color=bg+:#404040
    )
else
    selected=$(
        echo "$final_list" | fzf \
            --border=rounded --info=right \
            --color=fg:#000000,bg:#FFFFFF \
            --color=hl:#A5D6FF:reverse:bold,hl+:#79C0FF:reverse:bold \
            --color=info:#000000,separator:#000000,scrollbar:#000000 \
            --color=border:black,list-border:black,preview-border:black,input-border:black,header-border:black,footer-border:black \
            --color=fg+:#000000 \
            --color=bg+:#F2F2F2
    )
fi

[[ -z "$selected" ]] && exit 0
selected="${selected%/}"

# tmux session names cannot contain dots reliably; replace with underscores.
name="$(basename "$selected" | tr . _)"

# Create the session if missing, with its working directory set to the selected path.
tmux has-session -t "$name" 2>/dev/null || tmux new-session -ds "$name" -c "$selected"

# Switch to the selected session inside the current tmux client.
tmux switch-client -t "$name"
