#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompt - Hardcoded colors
RED='\[\033[38;2;211;138;149m\]'    # #d38a95
ROSE='\[\033[38;2;214;151;151m\]'   # #d69797
BLUE='\[\033[38;2;140;154;176m\]'   # #8c9ab0
PURPLE='\[\033[38;2;178;143;178m\]' # #b28fb2
GREEN='\[\033[38;2;143;173;158m\]'  # #8fad9e
RESET='\[\033[0m\]'
ROOT_RED='\[\033[38;5;1m\]'

# exit code of last process
PS1='$(ret=$?;(($ret!=0)) && echo "'$RED'($ret) '$RESET'")'
# username (purple, red for root)
PS1+=$PURPLE'$(((UID==0)) && echo "'$ROOT_RED'")\u@'
# hostname
PS1+='\h'$RESET' '
# cwd (current directory only)
PS1+=$BLUE'\W '
# optional git branch
PS1+='$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "'$ROSE'*'$GREEN'$branch ")'
# prompt character
PS1+=$BLUE'\$'$RESET' '

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
