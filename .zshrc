# Prompt (matching .bashrc)
# setopt PROMPT_SUBST
# PROMPT='%(!.%F{red}.)%n@%m%f'  # user@host (red for root)
# PROMPT+=':'  # separator
# PROMPT+='%1~'  # current directory
# PROMPT+='$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "(*$branch)")'  # git branch
# PROMPT+=' %# '  # prompt character

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
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

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
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-flags

# Aliases
alias vim='nvim'
alias codenohup='nohup code  >/dev/null 2>&1 &'
alias cursornohup='nohup cursor  >/dev/null 2>&1 &'
alias ls='eza -lh --group-directories-first --icons=auto'
alias ll='ls -l'
alias lt='eza --tree --level=2 --long --icons --git'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

alias cd="zd"
alias code="code  --ozone-platform=wayland "
alias pacl="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --height=80% --border"
alias yayl="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse --height=80% --border"

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
#eval "$(zoxide init --cmd cd zsh)"
eval "$(zoxide init zsh)"

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

autoload -Uz edit-command-line
zle -N edit-command-line

bindkey '^X^E' edit-command-line

export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
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

# Node version manager
source /usr/share/nvm/init-nvm.sh
