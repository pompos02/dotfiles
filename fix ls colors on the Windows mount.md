# Step 1 – Generate Default dircolors File
```bash
dircolors -p > ~/.dircolors
```

# Step 2 – Edit Highlight Rules

Open the file:
```bash
vim ~/.dircolors
```

find these lines
```bash
OTHER_WRITABLE 30;42
STICKY_OTHER_WRITABLE 30;42
```

Replace them with:
```bash
OTHER_WRITABLE 01;34
STICKY_OTHER_WRITABLE 01;34
```

This changes the background block highlight to a clean blue foreground color.

# Step 3 – Load Custom dircolors Automatically

**Add the following to your shell configuration:**
> Bash (~/.bashrc)
```bash
eval "$(dircolors ~/.dircolors)"
```
