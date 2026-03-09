# Build a compact version of the current working directory.
#
# Examples:
# - /home/user/projects/dotfiles     -> ~/p/dotfiles
# - /etc/nginx/sites-enabled         -> /e/n/sites-enabled
# - /home/user/.config/bash          -> ~/.c/bash
#
# The final path component is kept in full so the current directory stays easy to
# identify, while parent directories are shortened to reduce prompt width.
__prompt_native_set_short_pwd() {
	local path="$PWD"
	local prefix=""
	local out
	local part
	local i

	# Replace the user's home directory prefix with ~ so the prompt stays concise
	# and matches normal shell conventions.
	if [[ $path == "$HOME" || $path == "$HOME"/* ]]; then
		prefix="~"
		path="${path#"$HOME"}"
	fi

	# Split the remaining path into slash-delimited components so each part can
	# be shortened independently.
	local IFS=/
	local -a parts
	read -r -a parts <<<"${path#/}"

	out="$prefix"
	local last_index=$((${#parts[@]} - 1))

	# Keep the last directory name intact and shorten every parent directory.
	# Hidden directories keep their leading dot plus one extra character so
	# names like .config remain distinguishable.
	for i in "${!parts[@]}"; do
		part="${parts[$i]}"
		[[ -z $part ]] && continue

		if ((i == last_index)); then
			out+="/$part"
		elif [[ $part == .* ]]; then
			out+="/${part:0:2}"
		else
			out+="/${part:0:1}"
		fi
	done

	# If we ended up with nothing, we are at the filesystem root.
	[[ -n $out ]] || out="/"
	REPLY=$out
}

# Public helper used by the prompt
# It prints the shortened working directory to standard output.
short_pwd() {
	__prompt_native_set_short_pwd
	printf '%s' "$REPLY"
}

# Prompt color palette.
#
# The \[ ... \] wrappers tell Bash that these are non-printing escape
# sequences, which keeps line editing and cursor positioning correct.
__prompt_native_default='\[\e[39m\]'
__prompt_native_accent='\[\e[38;2;243;173;71m\]'
__prompt_native_danger='\[\e[38;2;244;56;65m\]'
__prompt_native_reset='\[\e[0m\]'

# Escape text before inserting it into PS1.
#
# Bash treats several characters specially inside prompt strings. Escaping them
# here prevents accidental prompt expansion or malformed rendering when branch
# names, paths, or repository identifiers contain special characters.
__prompt_native_escape_ps1() {
	local text=${1-}

	text=${text//\\/\\\\}
	text=${text//\$/\\$}
	text=${text//\`/\\\`}

	REPLY=$text
}

# Build the Git portion of the prompt.
#
# This parses `git status --porcelain=2` because it is intended for scripts and
# provides stable machine-readable status details. The segment includes:
# - the current branch, or HEAD plus a short hash when detached
# - ahead/behind information relative to the upstream branch
# - counts for conflicts, stash entries, deletions, renames, modifications,
#   staged changes, and untracked files
#
# The function stores the fully formatted prompt fragment in REPLY and returns a
# non-zero status when the current directory is not inside a Git repository.
__prompt_native_git_segment() {
	local status_output
	local line
	local xy
	local x
	local y
	local branch_head=""
	local branch_oid=""
	local branch_display
	local hash_text=""
	local all_status=""
	local ahead_behind=""
	local segment=""
	local show_stash_supported=1
	local conflicted=0
	local deleted=0
	local renamed=0
	local modified=0
	local staged=0
	local untracked=0
	local stash_count=0
	local ahead=0
	local behind=0

	# Prefer the built-in stash count from modern Git. If the installed Git does
	# not support `--show-stash`, fall back to a second command later.
	if ! status_output=$(command git status --porcelain=2 --branch --show-stash 2>/dev/null); then
		status_output=$(command git status --porcelain=2 --branch 2>/dev/null) || return 1
		show_stash_supported=0
	fi

	# Walk through each porcelain status line and accumulate the pieces we want
	# to display in the prompt.
	while IFS= read -r line; do
		case $line in
		'# branch.head '*)
			branch_head=${line#\# branch.head }
			;;
		'# branch.oid '*)
			branch_oid=${line#\# branch.oid }
			;;
		'# branch.ab +'*)
			line=${line#\# branch.ab +}
			ahead=${line%% -*}
			behind=${line#* -}
			;;
		'# stash '*)
			stash_count=${line#\# stash }
			;;
		'1 '* | '2 '*)
			xy=${line:2:2}
			x=${xy:0:1}
			y=${xy:1:1}

			case $x in
			D) ((deleted++)) ;;
			R | C) ((renamed++)) ;;
			A | M) ((staged++)) ;;
			esac

			case $y in
			D) ((deleted++)) ;;
			R | C) ((renamed++)) ;;
			M) ((modified++)) ;;
			esac
			;;
		'u '*)
			((conflicted++))
			;;
		'? '*)
			((untracked++))
			;;
		esac
	done <<<"$status_output"

	# Older Git versions do not report stash information in porcelain output, so
	# query the stash reflog directly when necessary.
	if ((!show_stash_supported)); then
		stash_count=$(command git rev-list --walk-reflogs --count refs/stash 2>/dev/null || printf '0')
	fi

	# If Git did not report a branch head, treat the directory as non-repository
	# or otherwise unusable for prompt rendering.
	[[ -n $branch_head ]] || return 1

	# Detached HEAD is rendered as HEAD plus a short object id so it is obvious
	# that the user is not currently on a named branch.
	if [[ $branch_head == '(detached)' ]]; then
		branch_display='HEAD'
		if [[ -n $branch_oid && $branch_oid != '(initial)' ]]; then
			hash_text=${branch_oid:0:7}
		fi
	else
		branch_display=$branch_head
	fi

	# Assemble compact counters for local repository state.
	((conflicted)) && all_status+="=${conflicted}"
	((stash_count)) && all_status+="*${stash_count}"
	((deleted)) && all_status+="x${deleted}"
	((renamed)) && all_status+="»${renamed}"
	((modified)) && all_status+="!${modified}"
	((staged)) && all_status+="+${staged}"
	((untracked)) && all_status+="?${untracked}"

	# Add upstream divergence information only when it exists.
	if ((ahead > 0 && behind > 0)); then
		ahead_behind="⇕⇡${ahead}⇣${behind}"
	elif ((ahead > 0)); then
		ahead_behind="⇡${ahead}"
	elif ((behind > 0)); then
		ahead_behind="⇣${behind}"
	fi

	# Escape user-controlled text before embedding it into PS1.
	__prompt_native_escape_ps1 "$branch_display"
	branch_display=$REPLY

	segment+="${__prompt_native_default}git://${__prompt_native_accent}${branch_display}"

	if [[ -n $hash_text ]]; then
		segment+="${__prompt_native_default} ${__prompt_native_danger}${hash_text}"
	fi

	if [[ -n $all_status || -n $ahead_behind ]]; then
		segment+="${__prompt_native_danger} ${all_status}${ahead_behind}"
	fi

	REPLY=$segment
}

# Build the Subversion portion of the prompt.
#
# This is only used when Git metadata is unavailable. The relative URL is a
# compact and stable way to show the current branch or tag location in SVN.
__prompt_native_svn_segment() {
	local relative_url

	relative_url=$(command svn info --show-item relative-url 2>/dev/null) || return 1
	relative_url=${relative_url#^/}
	__prompt_native_escape_ps1 "$relative_url"
	relative_url=$REPLY

	REPLY="${__prompt_native_default}svn://${__prompt_native_accent}${relative_url}"
}

# Compose the full interactive prompt.
#
# The prompt is rendered on two lines:
# - line 1 shows user, host, current directory, and optional VCS information
# - line 2 shows the input marker where commands are typed
#
# Bash executes PROMPT_COMMAND before displaying each primary prompt, which makes
# this function the central place for assembling dynamic prompt state.
__prompt_native_prompt_command() {
	local cwd
	local vcs_segment=""
	local line1

	# Shorten the current working directory and escape it for safe PS1 use.
	__prompt_native_set_short_pwd
	cwd=$REPLY
	__prompt_native_escape_ps1 "$cwd"
	cwd=$REPLY

	# Prefer Git metadata when available, otherwise fall back to Subversion.
	if __prompt_native_git_segment; then
		vcs_segment=$REPLY
	elif __prompt_native_svn_segment; then
		vcs_segment=$REPLY
	fi

	# Start the first line with user and host information.
	line1="${__prompt_native_default}┌[\\u@"
	line1+="\\h${__prompt_native_default}]-(${__prompt_native_accent}${cwd}${__prompt_native_default})"

	# Append repository status only when the current directory is versioned.
	if [[ -n $vcs_segment ]]; then
		line1+="${__prompt_native_default}-[${vcs_segment}${__prompt_native_default}]"
	fi

	PS1="${line1}"$'\n'"${__prompt_native_default}└> ${__prompt_native_reset}"
}

PROMPT_COMMAND=__prompt_native_prompt_command
