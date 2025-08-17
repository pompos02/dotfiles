return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        opts = {
            variant = "auto",
            dark_variant = "moon",
            dim_inactive_windows = false,
            
            styles = {
                bold = true,
                italic = true,
                transparency = true,
            },

            groups = {
                error = "love",
                hint = "iris", 
                info = "foam",
                warn = "gold",
            },
        },
    },
    -- Enhanced lualine for rose-pine vibrancy
    {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = function(_, opts)
            if
                vim.g.colors_name == "rose-pine"
                or vim.g.colors_name == "rose-pine-moon"
                or vim.g.colors_name == "rose-pine-main"
            then
                local rose_pine = require("rose-pine.palette")

                -- Create vibrant lualine theme
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

                opts.options = opts.options or {}
                opts.options.theme = vibrant_rose_pine
                opts.options.component_separators = { left = "", right = "" }
                opts.options.section_separators = { left = "", right = "" }
                opts.options.globalstatus = true -- Single statusline at bottom
                -- Minimal sections configuration
                opts.sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                return str:sub(1, 1)
                            end, -- Only first letter
                        },
                    },
                    lualine_b = { { "branch", icon = "" }, "diff" }, -- Empty
                    lualine_c = { { "filename", path = 1 } }, -- Just filename
                    lualine_x = { "diagnostics" }, -- Only diagnostics
                    lualine_y = { "lsp_status", "location" }, -- Empty
                    lualine_z = {
                        function()
                            return " " .. os.date("%R")
                        end,
                    },
                }

                -- ULTRA MINIMAL ALTERNATIVE (uncomment to use):
                -- opts.sections = {
                --     lualine_a = {},
                --     lualine_b = {},
                --     lualine_c = { "filename" },               -- Only filename in center
                --     lualine_x = {},
                --     lualine_y = {},
                --     lualine_z = { "location" },               -- Only location on right
                -- }
                -- Minimal inactive sections
                opts.inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                }
            end
            return opts
        end,
    },
    -- Configure LazyVim to load rose-pine-moon
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "rose-pine-moon",
        },
    },
}
