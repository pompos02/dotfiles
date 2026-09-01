# Dotfiles

Personal Arch Linux configuration aligned with the example repository layout.

## Install

Install packages first, then stow dotfiles:

```bash
cd ~/devel/environment/packages
./install

cd ~/devel/environment
./install
```

The package installer uses `hostname`:

- `zeno`: installs `packages/group/base`
- `plato`: installs `packages/group/base` and `packages/group/gui`

Dotfiles are not split by profile. `install` stows everything under `home/`:

```bash
stow --no-folding -R -v -t ~ -d ~/devel/environment/home .
```

## Packages

Package manifests are one package per line:

```text
packages/group/base
packages/group/gui
```

Host groups compose those manifests with symlinks:

```text
packages/group/plato/base -> ../base
packages/group/plato/gui  -> ../gui
packages/group/zeno/base  -> ../base
```

`packages/install` bootstraps `paru-bin` if needed and then installs every manifest
under `packages/group/$(hostname)/`.

## Bash

Shell configuration is split into ordered fragments under `home/.config/bash`:

- `environment`: login environment and PATH.
- `aliases`: command aliases.
- `functions`: interactive shell helpers.
- `history`: Bash history behavior.
- `prompt.bash`: native Bash prompt.

Zsh and Starship are not used.

## State

`init-state-files` creates empty local files required by the theme integrations:

```text
~/.local/state/theme/current
~/.cache/theme/current_fzf
~/.config/kitty/current-theme.conf
~/.config/alacritty/theme.toml
```

These files are not tracked or stowed. Applying a theme populates them.

Executables under `home/.local/bin` and scripts under `home/.config/scripts` are
both added to `PATH`. The `allmux` binary is vendored under `.local/bin` and used
by the tmux `f` binding.
