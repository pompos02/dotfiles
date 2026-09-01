#!/usr/bin/env bash

path=${1:-}
prefix=""

# Replace the user's home directory prefix with ~ so the prompt stays concise
# and matches normal shell conventions.
if [[ $path == "$HOME" || $path == "$HOME"/* ]]; then
	prefix="~"
	path="${path#"$HOME"}"
fi

# Split the remaining path into slash-delimited components so each part can
# be shortened independently.
IFS=/
read -r -a parts <<<"${path#/}"

out="$prefix"
last_index=$((${#parts[@]} - 1))

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
printf '%s\n' "$out"
