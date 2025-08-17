return {
    -- The rose-pine colorscheme plugin
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                variant = "auto",
                dark_variant = "moon",
                -- dim_inactive_windows = false,
                styles = {
                    transparency = true,
                },
                palette = {
                    moon = {
                        _nc = "#1f1d30",
                        base = "#232136",
                        surface = "#2a273f",
                        overlay = "#393552",
                        muted = "#6e6a86",
                        subtle = "#908caa",
                        text = "#e0def4",
                        love = "#eb6f92",
                        gold = "#f6c177",
                        rose = "#ea9a97",
                        pine = "#3e8fb0",
                        foam = "#9ccfd8",
                        iris = "#c4a7e7",
                        leaf = "#95b1ac",
                        highlight_low = "#2a283e",
                        highlight_med = "#44415a",
                        highlight_high = "#56526e",
                        none = "NONE",
                    },
                },
                highlight_groups = {
                    -- Change yank highlight color
                    IncSearch = { fg = "base", bg = "love" },
                },
            })
        end,
    },

    -- The lualine plugin
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "rose-pine/neovim" },
        config = function()
            local rose_pine = require("rose-pine.palette")

            -- Create the vibrant lualine theme based on your rose-pine palette
            local vibrant_rose_pine = {
                normal = {
                    a = { fg = rose_pine.base, bg = rose_pine.rose, gui = "bold" },
                    b = { fg = rose_pine.rose, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                insert = {
                    a = { fg = rose_pine.base, bg = rose_pine.foam, gui = "bold" },
                    b = { fg = rose_pine.foam, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                visual = {
                    a = { fg = rose_pine.base, bg = rose_pine.iris, gui = "bold" },
                    b = { fg = rose_pine.iris, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                replace = {
                    a = { fg = rose_pine.base, bg = rose_pine.love, gui = "bold" },
                    b = { fg = rose_pine.love, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                command = {
                    a = { fg = rose_pine.base, bg = rose_pine.pine, gui = "bold" },
                    b = { fg = rose_pine.pine, bg = rose_pine.base },
                    c = { fg = rose_pine.text, bg = rose_pine.base },
                },
                inactive = {
                    a = { fg = rose_pine.muted, bg = rose_pine.base },
                    b = { fg = rose_pine.muted, bg = rose_pine.base },
                    c = { fg = rose_pine.muted, bg = rose_pine.base },
                },
            }

            -- Set up lualine
            require("lualine").setup({
                options = {
                    theme = vibrant_rose_pine,
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return str:sub(1, 1)
                            end,
                        },
                    },
                    lualine_b = { { "branch", icon = "" }, "diff" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "diagnostics" },
                    lualine_y = { "lsp_status", "location" },
                    lualine_z = {
                        function()
                            return " " .. os.date("%R")
                        end,
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },
}
