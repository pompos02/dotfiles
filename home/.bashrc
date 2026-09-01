# shellcheck shell=bash

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

[[ -r "$config_home/bash/environment" ]] && source "$config_home/bash/environment"
[[ $- == *i* ]] || return

for fragment in aliases functions history; do
	[[ -r "$config_home/bash/$fragment" ]] && source "$config_home/bash/$fragment"
done

[[ -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion
command -v dircolors >/dev/null 2>&1 && eval "$(dircolors "$HOME/.dircolors")"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

[[ -r "$config_home/bash/prompt.bash" ]] && source "$config_home/bash/prompt.bash"
PROMPT_COMMAND=(__prompt_native_prompt_command 'history -a' 'history -n')

bind 'set completion-ignore-case on'
