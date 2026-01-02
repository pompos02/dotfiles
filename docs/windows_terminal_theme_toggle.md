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
