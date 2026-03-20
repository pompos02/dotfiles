set -gx BUN_INSTALL "$HOME/.bun"
set -gx ORACLE_HOME /opt/oracle/instantclient_19_29
set -gx LD_LIBRARY_PATH "$ORACLE_HOME"
set -gx TNS_ADMIN /opt/oracle/wallet
set -gx PKG_CONFIG_PATH /usr/local/lib/pkgconfig $PKG_CONFIG_PATH
set -gx EDITOR nvim
set -gx NVM_DIR "$HOME/.nvm"

fish_add_path -m /usr/local/bin
fish_add_path -m "$HOME/.local/bin"
fish_add_path -a -m "$HOME/go/bin"
fish_add_path -m "$HOME/.npm-global/bin"
fish_add_path -m "$HOME/.config/scripts"
fish_add_path -m "$HOME/.config/bin"
fish_add_path -m "$HOME/.opencode/bin"
fish_add_path -a -m /opt/nvim-linux-x86_64/bin
fish_add_path -a -m "$HOME/.fzf/bin"
fish_add_path -a -m /opt/sqlcl/bin
fish_add_path -m "$HOME/.cargo/bin"
fish_add_path -m "$BUN_INSTALL/bin"
fish_add_path -a -m "$HOME/.local/zig"
fish_add_path -a -m "$ORACLE_HOME"
fish_add_path -m /opt/oracle/instantclient_19_29/sdk

alias ls='ls --color=auto'
alias ll='ls -l'
alias python='python3'
alias grep='grep --color=auto'
alias vim='nvim'
alias bat='batcat'
alias good='git add . && git commit -m "good" && git push'
alias code='code --ozone-platform=wayland'
alias pacl="pacman -Slq | fzf --preview 'pacman -Si {}' --layout=reverse --height=80% --border"
alias yayl="yay -Slq | fzf --preview 'yay -Si {}' --layout=reverse --height=80% --border"

starship init fish | source
