-- Place this file in lua/plugins/lualine.lua
return {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    init = function()
        vim.g.lualine_laststatus = vim.o.laststatus
        if vim.fn.argc(-1) > 0 then
            -- set an empty statusline till lualine loads
            vim.o.statusline = " "
        else
            -- hide the statusline on the starter page
            vim.o.laststatus = 0
        end
    end,
    opts = function()
        -- Define icons
        local icons = {
            diagnostics = {
                Error = "󰅚 ",
                Warn = "󰀪 ",
                Info = " ",
                Hint = "󰌶 ",
            },
            git = {
                added = "󰜄 ",
                modified = "󰏫 ",
                removed = "󰍵 ",
            },
        }

        local palette = {
            bg = "#000000",
            nc = "#000000",
            base = "#1a1a1a",
            surface = "#111111",
            overlay = "#313131",
            muted = "#898989",
            subtle = "#b2b2b2",
            text = "#fbfbfb",
            red = "#c77889",
            gold = "#dfb591",
            rose = "#ba8d8d",
            blue = "#7c98b9",
            lavender = "#9f9fcf",
            purple = "#bb9dbd",
            green = "#a7c1bd",
            highlight_low = "#262626",
            highlight_med = "#4f4f4f",
            highlight_high = "#797979",
        }

        -- Define custom highlight groups for the branch component
        vim.api.nvim_set_hl(0, "LualineBDirectoryName", { fg = palette.subtle })
        vim.api.nvim_set_hl(0, "LualineBGitText", { fg = palette.text })
        vim.api.nvim_set_hl(0, "LualineBBranchName", { fg = palette.text })

        -- Set universal background color for statusline
        vim.api.nvim_set_hl(0, "StatusLine", { bg = palette.highlight_low })
        vim.api.nvim_set_hl(0, "StatusLineNC", { bg = palette.highlight_low })

        -- Helper function to safely get highlight color
        local function get_hl_color(group)
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            if ok and hl.fg then
                return string.format("#%06x", hl.fg)
            end
        end

        -- Custom branch component showing "directory git:(branch_name)"
        local function custom_branch_component()
            return {
                function()
                    -- Get current directory name
                    local cwd = vim.fn.getcwd()
                    local home = vim.env.HOME or vim.env.USERPROFILE
                    local dir_name
                    if cwd == home then
                        dir_name = "~"
                    else
                        dir_name = vim.fn.fnamemodify(cwd, ":t")
                    end

                    -- Get git branch
                    local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
                    if vim.v.shell_error ~= 0 or branch == "" then
                        return "%#LualineBDirectoryName#" ..
                            dir_name ..
                            "%*"         -- No git repo, just show directory in love color
                    end

                    return "%#LualineBDirectoryName#"
                        .. dir_name
                        .. "%*%#LualineBGitText#:%#LualineBBranchName#"
                        .. branch
                        .. "%#LualineBGitText#%*"
                end,
                color = { gui = "bold" },
            }
        end

        -- Pretty path component
        local function pretty_path_component()
            return {
                "filename",
                path = 1, -- Show relative path
                symbols = {
                    modified = "● ",
                    readonly = " ",
                    unnamed = "󰡯 ",
                },
            }
        end

        local lualine_require = require("lualine_require")
        lualine_require.require = require

        vim.o.laststatus = vim.g.lualine_laststatus

        local opts = {
            options = {
                theme = {
                    normal = {
                        a = { fg = palette.text, bg = palette.base },
                        b = { fg = palette.text, bg = palette.highlight_low },
                        c = { fg = palette.text, bg = palette.base },
                        x = { fg = palette.text, bg = palette.base },
                        y = { fg = palette.text, bg = palette.base },
                        z = { fg = palette.text, bg = palette.highlight_low },
                    },
                    insert = {
                        a = { fg = palette.text, bg = palette.base },
                        b = { fg = palette.text, bg = palette.highlight_low },
                        c = { fg = palette.text, bg = palette.base },
                        x = { fg = palette.text, bg = palette.base },
                        y = { fg = palette.text, bg = palette.base },
                        z = { fg = palette.text, bg = palette.highlight_low },
                    },
                    visual = {
                        a = { fg = palette.text, bg = palette.base },
                        b = { fg = palette.text, bg = palette.highlight_low },
                        c = { fg = palette.text, bg = palette.base },
                        x = { fg = palette.text, bg = palette.base },
                        y = { fg = palette.text, bg = palette.base },
                        z = { fg = palette.text, bg = palette.highlight_low },
                    },
                    replace = {
                        a = { fg = palette.text, bg = palette.base },
                        b = { fg = palette.text, bg = palette.highlight_low },
                        c = { fg = palette.text, bg = palette.base },
                        x = { fg = palette.text, bg = palette.base },
                        y = { fg = palette.text, bg = palette.base },
                        z = { fg = palette.text, bg = palette.highlight_low },
                    },
                    command = {
                        a = { fg = palette.text, bg = palette.base },
                        b = { fg = palette.text, bg = palette.highlight_low },
                        c = { fg = palette.text, bg = palette.base },
                        x = { fg = palette.text, bg = palette.base },
                        y = { fg = palette.text, bg = palette.base },
                        z = { fg = palette.text, bg = palette.highlight_low },
                    },
                    inactive = {
                        a = { fg = palette.muted, bg = palette.base },
                        b = { fg = palette.muted, bg = palette.highlight_low },
                        c = { fg = palette.muted, bg = palette.base },
                        x = { fg = palette.muted, bg = palette.base },
                        y = { fg = palette.muted, bg = palette.base },
                        z = { fg = palette.muted, bg = palette.highlight_low },
                    },
                },
                globalstatus = vim.o.laststatus == 3,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" },
                },
            },
            sections = {
                lualine_a = {},
                lualine_b = {
                    custom_branch_component(),
                },
                lualine_c = {
                    pretty_path_component(),
                    {
                        "diagnostics",
                        symbols = {
                            error = icons.diagnostics.Error,
                            warn = icons.diagnostics.Warn,
                            info = icons.diagnostics.Info,
                            hint = icons.diagnostics.Hint,
                        },
                    },
                },
                lualine_x = {
                    {
                        "diff",
                        symbols = {
                            added = icons.git.added,
                            modified = icons.git.modified,
                            removed = icons.git.removed,
                        },
                        diff_color = {
                            added = { fg = palette.green },
                            modified = { fg = palette.gold },
                            removed = { fg = palette.red },
                        },
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
                    -- DAP status
                    {
                        function()
                            if package.loaded["dap"] then
                                local status = require("dap").status()
                                return status ~= "" and "  " .. status or ""
                            end
                            return ""
                        end,
                        cond = function()
                            return package.loaded["dap"] and require("dap").status() ~= ""
                        end,
                        color = function()
                            return { fg = get_hl_color("Debug") }
                        end,
                    },

                    -- Lazy plugin updates
                    {
                        function()
                            if package.loaded["lazy"] then
                                return require("lazy.status").updates()
                            end
                            return ""
                        end,
                        cond = function()
                            return package.loaded["lazy"] and require("lazy.status").has_updates()
                        end,
                        color = function()
                            return { fg = get_hl_color("Special") }
                        end,
                    },

                    -- Active LSP clients
                    {
                        function()
                            local clients = {}

                            -- Try modern API first (Neovim 0.10+)
                            if vim.lsp.get_clients then
                                clients = vim.lsp.get_clients({ bufnr = 0 })
                            end

                            if #clients == 0 then
                                return ""
                            end

                            local names = {}
                            for _, client in ipairs(clients) do
                                -- Filter out null-ls/none-ls as it's not a real LSP
                                if client.name ~= "null-ls" and client.name ~= "none-ls" then
                                    table.insert(names, client.name)
                                end
                            end

                            if #names == 0 then
                                return ""
                            end

                            return "󰒋 " .. table.concat(names, " │ ")
                        end,
                        color = { fg = palette.highlight_high },
                    },
                },
                lualine_y = {
                    { "progress", padding = { left = 1, right = 1 } },
                    -- { "location", padding = { left = 0, right = 1 } },
                },
                lualine_z = {
                    function()
                        return os.date("%R")
                    end,
                },
            },
            extensions = { "neo-tree", "lazy", "fzf" },
        }

        -- Add trouble symbols if available
        if vim.g.trouble_lualine and package.loaded["trouble"] then
            local ok, trouble = pcall(require, "trouble")
            if ok then
                local symbols = trouble.statusline({
                    mode = "symbols",
                    groups = {},
                    title = false,
                    filter = { range = true },
                    format = "{kind_icon}{symbol.name:Normal}",
                    hl_group = "lualine_c_normal",
                })
                if symbols then
                    table.insert(opts.sections.lualine_c, {
                        symbols.get,
                        cond = function()
                            return vim.b.trouble_lualine ~= false and symbols.has()
                        end,
                    })
                end
            end
        end

        return opts
    end,
}
