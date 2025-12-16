#!/bin/bash
DIRS=(
    "$HOME/projects/"
    "$HOME"
    "$HOME/projects/personal"
    "$HOME/projects/opensource"
    "/mnt/c/Users/yiann"
)

# Create state directory if it doesn't exist
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
STATE_FILE="$STATE_DIR/last_session"

# Ensure directory exists
[[ ! -d "$STATE_DIR" ]] && mkdir -p "$STATE_DIR"

# Function to convert session name back to directory path
session_to_dir() {
    local session_name="$1"
    # Reverse the tr . _ operation and reconstruct path
    local dir_name
    dir_name=$(echo "$session_name" | tr _ .)

    # Get all possible directories from our DIRS
    local all_possible_dirs
    all_possible_dirs=$(find "${DIRS[@]}" -mindepth 1 -maxdepth 1 -type d ! -name ".*" 2>/dev/null)

    # Find directory whose basename matches the session name
    while IFS= read -r dir_path; do
        local basename_dir
        basename_dir=$(basename "$dir_path")
        if [[ "$basename_dir" == "$dir_name" ]]; then
            echo "$dir_path"
            return 0
        fi
    done <<<"$all_possible_dirs"
}

# Get current tmux session directory if we're in tmux
get_current_session_dir() {
    if [[ -n "$TMUX" ]]; then
        local current_session
        current_session=$(tmux display-message -p '#S' 2>/dev/null)
        if [[ -n "$current_session" ]]; then
            session_to_dir "$current_session"
        fi
    fi
}

# Get last session directory from state file
get_last_session_dir() {
    if [[ -f "$STATE_FILE" && -r "$STATE_FILE" ]]; then
        local last_dir
        # last_dir=$(cat "$STATE_FILE" 2>/dev/null | tr -d '\n' | xargs)
        last_dir=$(tr -d '\n' < "$STATE_FILE" | xargs)
        # Check if directory still exists and is in our search scope
        if [[ -n "$last_dir" && -d "$last_dir" ]]; then
            # Verify it's a directory we would find in our search
            local relative_path="${last_dir#"$HOME"/}"
            local all_dirs
            all_dirs=$(find "${DIRS[@]}" -mindepth 1 -maxdepth 1 -type d ! -name ".*" 2>/dev/null | sed "s|^$HOME/||")
            if echo "$all_dirs" | grep -q "^$relative_path$"; then
                echo "$last_dir"
            fi
        fi
    fi
}

if [[ $# -eq 1 ]]; then
    selected=$1
else
    # Get all directories
    all_dirs=$(find "${DIRS[@]}" -mindepth 1 -maxdepth 1 -type d ! -name ".*" |
        sed "s|^$HOME/||")

    # Get priority directory (previous session from state file)
    priority_dir=$(get_last_session_dir)

    # Build the directory list with priority directory first
    if [[ -n "$priority_dir" ]]; then
        # Convert to relative path for display
        priority_relative="${priority_dir#"$HOME"/}"

        # Remove priority dir from main list and put it first
        dir_list=$(echo "$all_dirs" | grep -v "^$priority_relative$")
        final_list=$(printf "%s\n%s" "$priority_relative" "$dir_list")
    else
        final_list="$all_dirs"
    fi

    # Use fzf to select
    selected_relative=$(echo "$final_list" | fzf-tmux -p 90%,60% \
        --border=rounded --padding=1 \
        --color=hl:67:bold:underline,hl+:67:bold:underline)

    if [[ -n "$selected_relative" ]]; then
        case "$selected_relative" in
            /*) selected="$selected_relative" ;;                    # absolute path (e.g. /mnt/c/...)
            ~*) selected="${selected_relative/#\~/$HOME}" ;;        # tilde expansion if ever shown
            *) selected="$HOME/$selected_relative" ;;               # default: relative to HOME
        esac
    fi
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)

if ! tmux has-session -t "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
    tmux select-window -t "$selected_name:1"
fi

# Save the current session directory before switching (so it becomes the "previous" session)
# Only save if we're currently in tmux and switching to a different session
if [[ -n "$TMUX" ]]; then
    current_session=$(tmux display-message -p '#S' 2>/dev/null)
    if [[ -n "$current_session" && "$current_session" != "$selected_name" ]]; then
        current_session_dir=$(get_current_session_dir)
        if [[ -n "$current_session_dir" ]]; then
            # Atomic write to prevent corruption
            echo "$current_session_dir" >"$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
            # Set proper permissions (user read/write only)
            chmod 600 "$STATE_FILE" 2>/dev/null
        fi
    fi
fi

if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$selected_name"
else
    tmux attach-session -t "$selected_name"
fi
