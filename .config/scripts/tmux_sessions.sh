#!/bin/bash

DIRS=(
	"$HOME/projects"
	"$HOME"
	"$HOME/projects/personal"
	"$HOME/projects/opensource"
	"$HOME/projects/misc"
	"/home"
	# "/mnt/c/Users/yiann"
)

THEME="dark"

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
folder_dirs="$(list_dirs)"

session_names="$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"
normalized_session_names="$(printf '%s\n' "$session_names" | tr '.' '_')"
active_sessions="$(printf '%s\n' "$session_names" | sed 's/$/*/')"

if [[ -n "$session_names" ]]; then
	# Remove dirs whose basename matches an existing session name.
	filtered_dirs="$({
		while IFS= read -r d; do
			base="$(basename "${d%/}")"
			base_normalized="${base//./_}"
			printf '%s\n' "$normalized_session_names" | grep -qxF "$base_normalized" && continue
			printf '%s\n' "$d"
		done <<< "$folder_dirs"
	})"
else
	filtered_dirs="$folder_dirs"
fi

final_list="$(printf '%s\n%s\n' "$active_sessions" "$filtered_dirs"  | awk 'NF')"


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


# Selection handling
if [[ "$selected" == *\* ]]; then
	name="${selected%\*}"
	tmux switch-client -t "$name"
	exit 0
fi

[[ -z "$selected" ]] && exit 0
selected="${selected%/}"

# tmux session names cannot contain dots reliably; replace with underscores.
name="$(basename "$selected" | tr . _)"

# Create the session if missing, with its working directory set to the selected path.
tmux has-session -t "$name" 2>/dev/null || tmux new-session -ds "$name" -c "$selected"

# Switch to the selected session inside the current tmux client.
tmux switch-client -t "$name"
