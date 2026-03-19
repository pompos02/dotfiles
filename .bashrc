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
export PATH="$HOME/.config/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin:"
export PATH="${PATH:+${PATH}:}/home/karavellas/.fzf/bin"
export PATH="$PATH:/opt/sqlcl/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# oracle environment variables
export ORACLE_HOME=/opt/oracle/instantclient_19_29
export LD_LIBRARY_PATH=$ORACLE_HOME
export PATH=$PATH:$ORACLE_HOME
export TNS_ADMIN=/opt/oracle/wallet
export PATH=/opt/oracle/instantclient_19_29/sdk:$PATH

[ -f "$HOME/.config/bash/prompt.bash" ] && . "$HOME/.config/bash/prompt.bash"

export HISTSIZE=5000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind "set completion-ignore-case on"

alias ls='ls --color=auto'
alias ll='ls -l'
alias python='python3'
alias grep='grep --color=auto'
alias vim='nvim'
alias bat='batcat'
alias good='git add . && git commit -m "good" && git push'

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

open() {
    if [[ -n ${WSL_DISTRO_NAME-} ]]; then
        explorer.exe "$@" >/dev/null 2>&1 &
    else
        xdg-open "$@" >/dev/null 2>&1 &
    fi
}

# Auto-start tmux on WSL login
if [[ -z "$TMUX" ]] && [[ -t 1 ]]; then
    tmux attach -t karavellas || tmux new -s karavellas
fi

export NVM_DIR="$HOME/.nvm"

nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    nvm "$@"
}
