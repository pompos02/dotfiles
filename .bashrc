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

extstats() {
  dir="${1:-.}"

  # detect terminal for color
  if [ -t 1 ]; then color=1; else color=0; fi

  find "$dir" -type f -name '*.*' -print |
  awk '
  {
    file = $0

    # Extract extension from last dot
    pos = match(file, /\.[^.]+$/)
    if (pos == 0)
      next   # skip files with no extension

    ext = substr(file, pos + 1)

    # Skip weird cases: empty extension or only dots
    if (ext == "" || ext ~ /^[.]+$/)
      next

    # Count files
    count[ext]++

    # Get lines + bytes
    cmd = "wc -lc < \"" file "\""
    cmd | getline res
    close(cmd)

    split(res, tmp)
    lines = tmp[1]
    bytes = tmp[2]

    total_lines[ext] += lines
    total_bytes[ext] += bytes
  }
  END {
    for (e in count)
      printf "%s\t%d\t%d\t%d\n", e, count[e], total_lines[e], total_bytes[e]
  }' |
  sort -k2,2nr |
  awk -v color="$color" '
  BEGIN {
    if (color) {
      CYAN="\033[36m"; GREEN="\033[32m"; YELLOW="\033[33m"
      MAGENTA="\033[35m"; RESET="\033[0m"
    } else {
      CYAN=GREEN=YELLOW=MAGENTA=RESET=""
    }

    printf CYAN "%-10s %10s %12s %12s %12s %12s %12s\n",
      "EXT", "FILES", "LINES", "BYTES", "SIZE", "AVG_LINES", "AVG_SIZE"
    printf "---------------------------------------------------------------------------------------------\n" RESET
  }

  function hr(bytes,    units,i) {
    split("B KB MB GB TB", units)
    for (i=1; bytes>=1024 && i<5; i++) bytes/=1024
    return sprintf("%.1f %s", bytes, units[i])
  }

  {
    ext=$1; files=$2; lines=$3; bytes=$4
    size=hr(bytes)
    avg_lines=(files>0?lines/files:0)
    avg_size=hr((files>0?bytes/files:0))

    printf GREEN "%-10s" RESET " ", ext
    printf YELLOW "%10d" RESET " %12d %12d ", files, lines, bytes
    printf MAGENTA "%12s %12.1f %12s" RESET "\n", size, avg_lines, avg_size
  }'
}

