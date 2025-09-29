# Dotfiles

Personal Arch Linux configuration files.

## Stow Configuration

### CLI only (minimal)

```bash
stow . -t ~ --ignore='hypr|waybar|kitty|dunst|ghostty|walker|minimal-install.sh|full-install.sh|.gitignore|README.md'
```

### Full desktop

```bash
stow . -t ~
```
