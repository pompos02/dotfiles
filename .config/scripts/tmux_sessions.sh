#!/usr/bin/env bash
set -Eeuo pipefail

# ---------- config ----------
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

main() {
	# Collect session names.
	local sessions=() normalized=()
	mapfile -t sessions < <(tmux list-sessions -F '#{session_name}')

	# Prepare input for fzf in a single stream (sessions first, then dirs).
	# Use awk to build a set of normalized session names and filter dirs by basename.
	local final_list
	final_list="$(
		{
			# Active sessions with trailing '*'
			for s in "${sessions[@]}"; do
				printf '%s*\n' "$s"
			done

			# One-level, non-hidden directories for each root
			for root in "${DIRS[@]}"; do
				[[ -d "$root" ]] || continue
				# glob: only immediate children; skip if none
				shopt -s nullglob
				for d in "$root"/*/; do
					# skip hidden dirs
					[[ "${d##*/}" == .*/ ]] && continue
					printf '%s\n' "${d%/}"
				done
				shopt -u nullglob
			done
		} |
		awk -v have_sessions="${#sessions[@]}" '
			BEGIN { FS="/"; OFS="/" }
			# First, read all session lines that end with "*"
			/\*$/ {
				s=$0; sub(/\*$/,"",s)
				ns=s; gsub(/\./,"_",ns)
				seen[ns]=1
				print $0
				next
			}
		# Then, for dir paths: filter out if basename normalized matches session
		{
			if (!have_sessions) { print; next }
				base=$NF
				nb=base; gsub(/\./,"_",nb)
				if (seen[nb]) next
					print
				}
		'
	)"

	[[ -n "$final_list" ]] || exit 0

	local selected
	selected="$(
		case "$THEME" in
			dark)
				fzf --border=rounded --info=right \
					--color=hl:#A5D6FF:reverse:bold,hl+:#79C0FF:reverse:bold \
					--color=info:white \
					--color=border:white,list-border:white,preview-border:white,input-border:white,header-border:white,footer-border:white \
					--color=fg+:#FFFFFF \
					--color=bg+:#404040
				;;
			*)
				fzf --border=rounded --info=right \
					--color=fg:#000000,bg:#FFFFFF \
					--color=hl:#A5D6FF:reverse:bold,hl+:#79C0FF:reverse:bold \
					--color=info:#000000,separator:#000000,scrollbar:#000000 \
					--color=border:black,list-border:black,preview-border:black,input-border:black,header-border:black,footer-border:black \
					--color=fg+:#000000 \
					--color=bg+:#F2F2F2
				;;
		esac <<<"$final_list"
		)" || exit 0  # fzf returns nonzero on cancel

		[[ -n "$selected" ]] || exit 0

		# Selection handling
		if [[ "$selected" == *\* ]]; then
			tmux switch-client -t "${selected%\*}"
			exit 0
		fi

		local dir name
		dir="$selected"
		name="$(basename "$dir")"
		name="${name//./_}"

		# Create session only if missing; then switch.
		tmux has-session -t "$name" 2>/dev/null || tmux new-session -d -s "$name" -c "$dir"
		tmux switch-client -t "$name"
	}

main "$@"
