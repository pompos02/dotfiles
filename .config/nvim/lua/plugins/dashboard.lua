-- Minimal LazyVim Dashboard with Custom ASCII Art
return {
    {
        "snacks.nvim",
        opts = {
            dashboard = {
                enabled = true,
                preset = {
                    -- Your custom ASCII art goes here
                    header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
                    ]],
                    -- Simple keybindings
                    keys = {
                        {
                            icon = "",
                            key = "f",
                            desc = "Find File",
                            action = ":lua Snacks.dashboard.pick('files')",
                        },
                        {
                            icon = "",
                            key = "r",
                            desc = "Recent Files",
                            action = ":lua Snacks.dashboard.pick('oldfiles')",
                        },
                        {
                            icon = "",
                            key = "g",
                            desc = "Find Text",
                            action = ":lua Snacks.dashboard.pick('live_grep')",
                        },
                    },
                },
                -- Minimal sections
                sections = {
                    { section = "header" },
                    -- { section = "keys", gap = 1, padding = 1 },
                },
            },
        },
    },
}
