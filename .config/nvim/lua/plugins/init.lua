return {
    -- The rose-pine colorscheme plugin
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                variant = "auto",
                dark_variant = "moon",
                dim_inactive_windows = true,
                disable_float_background = true,
                styles = {
                    transparency = false,
                },
                palette = {
                    moon = {
                        bg = "#0f0e1a",
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
                    Normal = { fg = "text", bg = "bg" },
                    IncSearch = { fg = "base", bg = "love" },
                    -- Set floating windows to use terminal background
                    NormalFloat = { fg = "text", bg = "bg" },
                    FloatBorder = { fg = "muted", bg = "bg" },
                    -- Snacks picker specific
                    SnacksPicker = { fg = "text", bg = "bg" },
                    SnacksPickerBorder = { fg = "muted", bg = "bg" },
                    SnacksPickerList = { fg = "text", bg = "bg" },
                    SnacksPickerPreview = { fg = "text", bg = "bg" },
                    SnacksPickerInput = { fg = "text", bg = "bg" },
                    -- Active line highlighting
                    CursorLine = { bg = "highlight_low" },
                    -- Visual selection highlighting
                    Visual = { bg = "iris" },
                    -- Keywords (package, import, type, func, etc.)
                    Keyword = { fg = "love" },
                    ["@keyword"] = { fg = "love" },
                    ["@keyword.function"] = { fg = "love" },
                    ["@keyword.import"] = { fg = "love" },
                    ["@keyword.type"] = { fg = "love" },
                    ["@keyword.return"] = { fg = "love" },

                    -- Strings and struct tags
                    String = { fg = "gold" },
                    ["@tag"] = { fg = "rose" },

                    -- Variables and parameters
                    Identifier = { fg = "text" },
                    ["@variable"] = { fg = "text" },
                    ["@parameter"] = { fg = "text" },

                    -- Struct names and custom types
                    Type = { fg = "foam" },
                    ["@type"] = { fg = "foam" },
                    ["@type.definition"] = { fg = "foam" },
                    Structure = { fg = "foam" },

                    -- Function names and struct fields
                    Function = { fg = "iris", bold = true },
                    ["@function"] = { fg = "iris", bold = true },
                    ["@function.call"] = { fg = "iris", bold = true },
                    ["@field"] = { fg = "iris", bold = true },
                    ["@property"] = { fg = "iris", bold = true },

                    -- Built-in types (string, error, etc.)
                    ["@type.builtin"] = { fg = "pine" },
                    ["@keyword.type.builtin"] = { fg = "pine" },
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
                    lualine_y = {
                        {
                            function()
                                local clients = vim.lsp.get_clients({ bufnr = 0 })
                                if #clients == 0 then
                                    return ""
                                end
                                local names = {}
                                for _, client in ipairs(clients) do
                                    table.insert(names, "✓" .. client.name)
                                end
                                return table.concat(names, " ")
                            end,
                            color = { fg = rose_pine.foam },
                        },
                        "location",
                    },
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
