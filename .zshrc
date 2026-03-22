# Plugin manager
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Prompt theme
eval "$(starship init zsh)"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
zinit light zsh-users/zsh-completions
# zinit light zsh-users/zsh-autosuggestions

# Snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Completion initialization
autoload -Uz compinit && compinit

zinit cdreplay -q

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# Aliases
alias vim='nvim'
alias ls='eza -lh --group-directories-first --icons=auto'
alias ll='ls -l'
alias lt='eza --tree --level=2 --long --icons --git'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

alias code="code  --ozone-platform=wayland "
alias pacl="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --height=80% --border"
alias yayl="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse --height=80% --border"
alias good='git add . && git commit -m "good" && git push'

# Functions
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf  "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}
open() {
  if [[ -n ${WSL_DISTRO_NAME-} ]]; then
    explorer.exe "$@" >/dev/null 2>&1 &
  else
    xdg-open "$@" >/dev/null 2>&1 &
  fi
}

# Shell integrations
eval "$(fzf --zsh)"

# PATH
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.config/scripts:$PATH"
export PATH="$HOME/.config/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin:"
export PATH="${PATH:+${PATH}:}/home/karavellas/.fzf/bin"
export PATH="$PATH:/opt/sqlcl/bin"
export PATH="$HOME/.cargo/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:$HOME/.local/zig"

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# Oracle environment variables
export ORACLE_HOME=/opt/oracle/instantclient_19_29
export LD_LIBRARY_PATH=$ORACLE_HOME
export PATH=$PATH:$ORACLE_HOME
export TNS_ADMIN=/opt/oracle/wallet
export PATH=/opt/oracle/instantclient_19_29/sdk:$PATH

export NVM_DIR="$HOME/.nvm"

# Better lazy-loaded conda that also enables completions
# Lazy load conda to speed up shell
conda() {
  unset -f conda
  . "/opt/miniconda3/etc/profile.d/conda.sh"
  conda "$@"
}

# Keybindings
bindkey -e
export KEYTIMEOUT=1
bindkey '^U' backward-kill-line

# Ctrl+Arrow word movement
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[5C' forward-word
bindkey '^[[5D' backward-word

# Home/End line movement
[[ -n ${terminfo[khome]} ]] && bindkey -- "${terminfo[khome]}" beginning-of-line
[[ -n ${terminfo[kend]} ]] && bindkey -- "${terminfo[kend]}" end-of-line
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line

autoload -Uz edit-command-line
zle -N edit-command-line

bindkey '^X^E' edit-command-line

export EDITOR=nvim

# this is for macbook
# export PATH=$PATH:/Users/yianniscaravellas/go/bin
export PATH="$PATH:$HOME/go/bin"

export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/lib/jvm/java-24-openjdk/bin:$PATH"

# Dart completion
## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/karavellas/.dart-cli-completion/zsh-config.zsh ]] && . /home/karavellas/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# opencode
export PATH=/home/karavellas/.opencode/bin:$PATH

# Functions
pkillf() {
  ps -ef | fzf --height 40% --layout=reverse | awk '{print $2}' | xargs kill
}

my_ip() {
  ip address | grep -o "inet 192.*/" | awk '{ print $2 }' | tr / ' ' | xargs
}

man() {
  nvim -c "Man $* | only"
}

nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  nvm "$@"
}


# Auto-start tmux on login
if [[ -z "$TMUX" ]] && [[ -t 1 ]]; then
    tmux attach -t karavellas || tmux new -s karavellas
fi
