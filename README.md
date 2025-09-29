# Dotfiles

Personal Arch Linux configuration files.

## Stow Configuration

### CLI only (minimal)

```bash
stow . -t ~ --ignore='hypr' --ignore='waybar' --ignore='kitty' --ignore='dunst' --ignore='ghostty' --ignore='walker'
```

### Full desktop

```bash
stow . -t ~
```
