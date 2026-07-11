#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

materialize_config_dir() {
	local app="$1" config_file="$2" generated_file="$3"
	local dir="$CONFIG_HOME/$app" repo_config="$DOTFILES_DIR/.config/$app/$config_file"
	local tmp=''

	if [[ -L "$dir" ]]; then
		tmp="$(mktemp -d)"
		[[ -e "$dir/$generated_file" ]] && cp --dereference --preserve=mode "$dir/$generated_file" "$tmp/$generated_file"
		rm "$dir"
		mkdir -p -- "$dir"
		[[ -e "$tmp/$generated_file" ]] && mv "$tmp/$generated_file" "$dir/$generated_file"
		rmdir "$tmp" 2>/dev/null || true
	else
		mkdir -p -- "$dir"
	fi

	if [[ ! -e "$dir/$config_file" && -e "$repo_config" ]]; then
		ln -s "$repo_config" "$dir/$config_file"
	fi
}

materialize_config_dir kitty kitty.conf current-theme.conf
materialize_config_dir alacritty alacritty.toml theme.toml

mkdir -p -- "$STATE_HOME/theme" "$CACHE_HOME/theme"

theme="${1:-}"
if [[ -z "$theme" && -f "$STATE_HOME/theme/current" ]]; then
	theme="$(<"$STATE_HOME/theme/current")"
fi
theme="${theme:-dolores-yblow}"

"$CONFIG_HOME/theme/theme.sh" apply "$theme"
