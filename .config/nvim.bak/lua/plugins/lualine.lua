return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    enabled = false,
    opts = function()
        local lualine_require = require("lualine_require")
        lualine_require.require = require
        vim.o.laststatus = vim.g.lualine_laststatus

        return {
            options = {
                globalstatus = vim.o.laststatus == 3,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
                },
            },
            sections = {
                lualine_a = {
                    { "branch", icons_enabled = false, padding = 1 },
                },
                lualine_b = {
                    { "filename", padding = 1 },
                },
                lualine_c = {
                    {
                        "diff",
                        symbols = {
                            added = "+",
                            modified = "~",
                            removed = "-",
                        },
                        padding = 1,

                        source = function()
                            local gitsigns = vim.b.gitsigns_status_dict
                            if gitsigns then
                                return {
                                    added = gitsigns.added,
                                    modified = gitsigns.changed,
                                    removed = gitsigns.removed,
                                }
                            end
                        end,
                    },
                },
                lualine_x = {
                    {
                        "diagnostics",
                        symbols = {
                            error = "E:",
                            warn = "W:",
                            info = "I:",
                            hint = "H:",
                        },
                        padding = 1,
                    },
                },
                lualine_y = {
                    {
                        "lsp_status",
                        icons_enabled = false,
                        symbols = {
                            done = "",
                            separator = ":",
                        },
                        ignore_lsp = { "null-ls" },
                        show_name = true,
                        padding = 1,
                    },
                },
                lualine_z = { { "datetime", style = "%H:%M", padding = 1 } },
            },
        }
    end,
}
