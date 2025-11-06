#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
# because `master` is sometimes `main` (or others), these must be functions.
gmb() { # git main branch
    local main
    main=$(git symbolic-ref --short refs/remotes/origin/HEAD)
    main=${main#origin/}
    [[ -n $main ]] || return 1
    echo "$main"
}

# show the diff from inside a branch to the main branch
gbd() { # git branch diff
    local mb=$(gmb) || return 1
    git diff "$mb..HEAD"
}

# checkout the main branch and update it
gcm() { # git checkout $main
    local mb=$(gmb) || return 1
    git checkout "$mb" && git pull
}

# merge the main branch into our branch
gmm() { # git merge $main
    local mb=$(gmb) || return 1
    git merge "$mb"
}

# Prompt
# Store `tput` colors for future use to reduce fork+exec
# the array will be 0-255 for colors, 256 will be sgr0
# and 257 will be bold
COLOR256=()
COLOR256[0]=$(tput setaf 1)
COLOR256[256]=$(tput sgr0)
COLOR256[257]=$(tput bold)

# Colors for use in PS1 that may or may not change when
# set_prompt_colors is run
PROMPT_COLORS=()

# Custom color palette using RGB
declare -A PALETTE=(
    [red]="#d38a95"
    [gold]="#d3a677"
    [rose]="#d69797"
    [blue]="#8c9ab0"
    [lavender]="#a2a2c7"
    [purple]="#b28fb2"
    [green]="#8fad9e"
    [text]="#dbdbdb"
)

# Convert hex to RGB and create tput color
hex_to_tput() {
    local hex=$1
    hex=${hex#\#}
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

# Change the prompt colors to a theme, themes are 0-29
set_prompt_colors() {
    # Using the custom palette colors
    PROMPT_COLORS[0]=$(hex_to_tput "${PALETTE[red]}")
    PROMPT_COLORS[1]=$(hex_to_tput "${PALETTE[gold]}")
    PROMPT_COLORS[2]=$(hex_to_tput "${PALETTE[rose]}")
    PROMPT_COLORS[3]=$(hex_to_tput "${PALETTE[blue]}")
    PROMPT_COLORS[4]=$(hex_to_tput "${PALETTE[lavender]}")
    PROMPT_COLORS[5]=$(hex_to_tput "${PALETTE[purple]}")
    PROMPT_COLORS[6]=$(hex_to_tput "${PALETTE[green]}")
    PROMPT_COLORS[7]=$(hex_to_tput "${PALETTE[text]}")
}

# exit code of last process
PS1='$(ret=$?;(($ret!=0)) && echo "\[${PROMPT_COLORS[0]}\]($ret) \[${COLOR256[256]}\]")'

# username (red for root)
PS1+='\[${PROMPT_COLORS[5]}\]$(((UID==0)) && echo "\[${COLOR256[0]}\]")\u@'

# hostname
PS1+='\h\[${COLOR256[256]}\] '

# cwd (current directory only)
PS1+='\[${PROMPT_COLORS[3]}\]\W '

# optional git branch
PS1+='$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "\[${PROMPT_COLORS[2]}\]*\[${PROMPT_COLORS[6]}\]$branch ")'

# prompt character
PS1+='\[${PROMPT_COLORS[3]}\]\$\[${COLOR256[256]}\] '

# set the theme
set_prompt_colors

export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind "set completion-ignore-case on"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias codenohup='nohup code  >/dev/null 2>&1 &'
alias cursornohup='nohup cursor  >/dev/null 2>&1 &'
alias gs='git status'
alias ..="cd .."
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias code="code  --ozone-platform=wayland "
alias pacl="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --height=80% --border"
alias yayl="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse --height=80% --border"

eval "$(fzf --bash)"
# opencode
export PATH=/home/karavellas/.opencode/bin:$PATH
# this is the node version manager
source /usr/share/nvm/init-nvm.sh
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export EDITOR=nvim
export PATH="$HOME/.npm-global/bin:$PATH"

# vim motions
set -o vi

pkillf() {
    ps -ef | fzf --height 40% --layout=reverse | awk '{print $2}' | xargs kill
}

my_ip() {
    ip address | grep -o "inet 192.*/" | awk '{ print $2 }' | tr / ' ' | xargs
}

open() {
    xdg-open "$@" >/dev/null 2>&1 &
}

conda() {
    unset -f conda
    . "/opt/miniconda3/etc/profile.d/conda.sh"
    conda "$@"
}

man() {
    if [ $# -eq 0 ]; then
        local page
        page=$(apropos . | awk '{print $1}' | sort -u | fzf --preview "man {}" --preview-window "right:60%" --height=40% --layout=reverse)
        [ -n "$page" ] && nvim -c "Man $page"
    else
        nvim -c "Man $* | only"
    fi
}
