# shellcheck shell=sh

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

[ -r "$config_home/bash/environment" ] && . "$config_home/bash/environment"

if [ -n "${BASH_VERSION:-}" ] && [ -r "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
fi
