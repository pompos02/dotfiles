# Dotfiles

Personal Arch Linux configuration files.

## Stow Configuration

### CLI only (minimal)

```bash
stow . -t ~ --ignore='hypr|waybar|kitty|dunst|ghostty|rofi|minimal-install.sh|full-install.sh|.gitignore|README.md'
```

### Full desktop

```bash
stow . -t ~
```

## Symlink Selected Files Only

If you just want a handful of files and directories, you can create symlinks directly:

```bash
REPO="$HOME/dotfiles"
for p in .vimrc .config/nvim .config/tmux .config/scripts .bashrc; do
  mkdir -p "$HOME/$(dirname "$p")"
  ln -sfn "$REPO/$p" "$HOME/$p"
done
```
