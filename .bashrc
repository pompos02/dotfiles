#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.config/scripts:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin:"
export PATH="${PATH:+${PATH}:}/home/karavellas/.fzf/bin"
export PATH="$PATH:/opt/sqlcl/bin"

# oracle environment variables
export ORACLE_HOME=/opt/oracle/instantclient_19_29
export LD_LIBRARY_PATH=$ORACLE_HOME
export PATH=$PATH:$ORACLE_HOME
export TNS_ADMIN=/opt/oracle/wallet
export PATH=/opt/oracle/instantclient_19_29/sdk:$PATH


# #  # tmux can start bash with empty/invalid PWD; \W then prints nothing
#   if [[ -z $PWD || ! -d $PWD ]]; then
#     PWD="$(pwd)"
#   fi

# Prompt
PS1='$(ret=$?;(($ret!=0)) && echo "\[\033[38;5;1m\]($ret)\[\033[0m\] ")'  # exit code (red)
PS1+='$(((UID==0)) && echo "\[\033[38;5;1m\]")\u@\h\[\033[0m\]'  # user@host (red for root)
PS1+=':'  # separator
PS1+='\W'  # current directory
PS1+='$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "($branch*)")'  # git branch
PS1+=' \$ '  # prompt character

export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind "set completion-ignore-case on"

alias ls='ls --color=auto'
alias python='python3'
alias grep='grep --color=auto'
alias vim='nvim'
alias bat='batcat'
# alias ..="cd .."


eval "$(fzf --bash)"

# this is the node version manager
# source /usr/share/nvm/init-nvm.sh

export EDITOR=nvim

pkillf() {
    ps -ef | fzf --height 40% --layout=reverse | awk '{print $2}' | xargs kill
}

my_ip() {
    ip address | grep -o "inet 192.*/" | awk '{ print $2 }' | tr / ' ' | xargs
}


conda() {
    unset -f conda
    . "/opt/miniconda3/etc/profile.d/conda.sh"
    conda "$@"
}

man() {
    nvim -c "Man $* | only"
}

# Arch/Wayland specific
alias code="code  --ozone-platform=wayland "
alias pacl="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --height=80% --border"
alias yayl="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse --height=80% --border"

# open() {
#     xdg-open "$@" >/dev/null 2>&1 &
# }
open() {
    explorer.exe "$@" >/dev/null 2>&1 &
}

# Auto-start tmux on WSL login
if [[ -z "$TMUX" ]] && [[ -n "$WSL_DISTRO_NAME" ]] && [[ -t 1 ]]; then
    tmux attach -t karavellas || tmux new -s karavellas
fi

# uncomment this to be able to use nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# fix the ls colros in the windows mount
eval "$(dircolors ~/.dircolors)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
