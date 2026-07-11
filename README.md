# Dotfiles

Personal Arch Linux configuration files.

## Stow Configuration

### CLI only (minimal)

```bash
stow . -t ~ --ignore='hypr|waybar|kitty|dunst|ghostty|rofi|kde|minimal-install.sh|full-install.sh|.gitignore|README.md' \
  && stow kde -t ~
```

### Full desktop

```bash
stow . -t ~ --ignore='kde' && stow kde -t ~

```

### Restowing
```bash
stow -Rv . -t "$HOME" --ignore='kde|docs|minimal-install.sh|full-install.sh|.gitignore|README.md' && stow -Rv kde -t "$HOME"
./generate-state-files.sh
```


Do not run plain `stow . -t ~` anymore. Now that the repo contains a dedicated `kde/` package, doing that would try to link the `kde` directory itself into `~` instead of stowing its contents.

### KDE color schemes only

```bash
stow kde -t ~
```

Generate machine-local theme state after stowing:

```bash
./generate-state-files.sh
```

The KDE package only tracks portable color schemes under `.local/share/color-schemes`. KDE runtime config files under `.config` are intentionally machine-local.

If KDE color schemes already exist in `$HOME`, move them aside first and preview the link plan:

```bash
mkdir -p ~/kde-dotfiles-backup/.local/share/color-schemes
mv ~/.local/share/color-schemes/Yara.colors ~/kde-dotfiles-backup/.local/share/color-schemes/
stow -nvv kde -t ~
stow kde -t ~
```

## Symlink Selected Files Only

If you just want a handful of files and directories, you can create symlinks directly:

```bash
REPO="$HOME/dotfiles"
for p in .vimrc .config/nvim .config/tmux .config/scripts .bashrc .inputrc; do
  mkdir -p "$HOME/$(dirname "$p")"
  ln -sfn "$REPO/$p" "$HOME/$p"
done
```
