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

Do not run plain `stow . -t ~` anymore. Now that the repo contains a dedicated `kde/` package, doing that would try to link the `kde` directory itself into `~` instead of stowing its contents.

### KDE only

```bash
stow kde -t ~
```

If KDE config files already exist in `$HOME`, move them aside first and preview the link plan:

```bash
mkdir -p ~/kde-dotfiles-backup/.config ~/kde-dotfiles-backup/.local/share/color-schemes
mv ~/.config/kglobalshortcutsrc ~/kde-dotfiles-backup/.config/
mv ~/.config/kwinrc ~/kde-dotfiles-backup/.config/
mv ~/.config/kdeglobals ~/kde-dotfiles-backup/.config/
mv ~/.config/kwinrulesrc ~/kde-dotfiles-backup/.config/
mv ~/.config/kcminputrc ~/kde-dotfiles-backup/.config/
mv ~/.config/breezerc ~/kde-dotfiles-backup/.config/
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
