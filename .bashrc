#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
PS1='[\u@\h \W]\$ '

export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind "set completion-ignore-case on"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias vim='nvim'
alias c='clear'
alias codenohup='nohup code  >/dev/null 2>&1 &'
alias cursornohup='nohup cursor  >/dev/null 2>&1 &'
alias gs='git status'
alias my_ip="ip address | grep -o \"inet 192.*/\" | awk '{ print \$2 }' | tr / ' ' | xargs"
alias ..="cd .."
alias lsa='ls -la'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias code="code  --ozone-platform=wayland "
alias pacl="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --height=80% --border"
alias yayl="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse --height=80% --border"
alias pkillf='ps -ef | fzf --height 40% --layout=reverse | awk "{print \$2}" | xargs kill'

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

open() {
    xdg-open "$@" >/dev/null 2>&1 &
}

conda() {
    unset -f conda
    . "/opt/miniconda3/etc/profile.d/conda.sh"
    conda "$@"
}
