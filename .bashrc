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
export PATH="$HOME/.cargo/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# oracle environment variables
export ORACLE_HOME=/opt/oracle/instantclient_19_29
export LD_LIBRARY_PATH=$ORACLE_HOME
export PATH=$PATH:$ORACLE_HOME
export TNS_ADMIN=/opt/oracle/wallet
export PATH=/opt/oracle/instantclient_19_29/sdk:$PATH


short_pwd() {
    local path="$PWD"
    local prefix=""

    if [[ "$path" == "$HOME"* ]]; then
        prefix="~"
        path="${path#"$HOME"}"
    fi

    local IFS=/
    local -a parts
    read -ra parts <<< "${path#/}"

    local out="$prefix"
    local last_index=$((${#parts[@]}-1))

        for i in "${!parts[@]}"; do
            local part="${parts[$i]}"
            if [[ -z "$part" ]]; then
                continue
            fi

            if [[ $i -eq $last_index ]]; then
                out+="/$part"
            elif [[ $part == .* ]]; then
                out+="/${part:0:2}"
            else
                out+="/${part:0:1}"
            fi
        done

        [[ -z "$out" ]] && out="/"
        echo "$out"
    }

PS1='┌\[\033[39m\]'
PS1+='[\u@\h]-('
PS1+='\[\033[38;5;226m\]$(short_pwd)\[\033[0m\])'
PS1+='$(branch=$(git branch --show-current 2>/dev/null); if [[ -n $branch ]]; then  echo "\[\033[39m\]-[\[\033[92m\]$branch\[\033[0m\]\[\033[39m\]]\[\033[0m\]"; fi)'  # git branch + upstream (bright green)
PS1+='\n└> '


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
alias lazy='NVIM_APPNAME=lazy nvim'


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

export NVM_DIR="$HOME/.nvm"

nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    nvm "$@"
}
