#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Simple prompt without colors
PS1='$(ret=$?;(($ret!=0)) && echo "\[\033[38;5;1m\]($ret)\[\033[0m\] ")'  # exit code (red)
PS1+='$(((UID==0)) && echo "\[\033[38;5;1m\]")\u@\h\[\033[0m\]'  # user@host (red for root)
PS1+=':'  # separator
PS1+='\W'  # current directory
PS1+='$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "(*$branch)")'  # git branch
PS1+=' \$ '  # prompt character

export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind "set completion-ignore-case on"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
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
export PATH="$HOME/.config/scripts:$PATH"

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

extstats() { "$HOME/.config/scripts/extstats.sh"; }

