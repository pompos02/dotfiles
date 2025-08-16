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
                },
                -- Minimal sections
                sections = {
                    { section = "header" },
                    { section = "terminal",
                        cmd = "echo 'NVIM v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch .. "'",
                        height = 1,
                        padding = 1,
                        align = "center"
                    },
                    -- { section = "keys", gap = 1, padding = 1 },
                },
            },
        },
    },
}
