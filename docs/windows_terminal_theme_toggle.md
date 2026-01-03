# how to setup the thing

You should add this in the settings.json, dont forget this should go under the
keybinds table.

then the malakia will generate some extra code for this once you save to fully 
set it up
```json
  "keybindings": [
    {
      "command": {
        "action": "sendInput",
        "input": "~/.config/scripts/theme-toggle.sh\r"
      },
      "keys": "f12"
    }
  ]
```

This above doesnt always work depending on the screen you are in, if you want 
universal support use this:

```json
  "keybindings": [
    {
      "command": {
        "action": "newTab",
        "commandline": "wsl.exe -e bash -lc \"~/.config/scripts/theme-toggle.sh\""
      },
      "keys": "f12"
    }
  ]
```

But this always creates a new window
