-- ~/.config/nvim/lua/Karavellas/plugins/snacks.lua
return {
    "folke/snacks.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    priority = 1000, -- Ensure early loading for snacks.nvim
    lazy = false, -- Load immediately to avoid lazy-loading issues
    opts = {

        explorer = {
            enabled = true, -- Enable the explorer module
            width = 40, -- Set explorer window width
            side = "left", -- Position explorer on the left
            replace_netrw = true, -- Replace netrw with snacks explorer
            default_collapsed = true, -- Start explorer collapsed
            hidden = true, -- Show hidden files by default
            ignored = true, -- Show git-ignored files (e.g., .env) by default
        },
        picker = {
            enabled = true, -- Enable the picker module
            matchers = {
                frecency = true,
                cwd_bonus = false,
            },
            formatters = {
                file = {
                    filename_first = false,
                    filename_only = false,
                    icon_width = 2,
                },
            },
            layout = {
                -- presets options : "default" , "ivy" , "ivy-split" , "telescope" , "vscode", "select" , "sidebar"
                -- override picker layout in keymaps function as a param below
                preset = "telescope", -- defaults to this layout unless overidden
                cycle = false,
            },

            sources = {
                explorer = {
                    -- Explorer picker configuration
                    prompt = "File Explorer> ", -- Custom prompt
                    layout = {
                        preset = "sidebar", -- Use sidebar layout
                        preview = true, -- Enable preview pane
                        position = "left", -- Ensure explorer opens on the left
                    },
                    hidden = true, -- Show hidden files by default
                    ignored = true, -- Show git-ignored files (e.g., .env) by default
                    git_untracked = true, -- Show untracked git files
                    follow_file = true, -- Auto-focus current file
                    watch = true, -- Watch for filesystem changes
                    diagnostics = true, -- Show diagnostics in explorer
                    auto_close = true, -- Close picker after confirming selection
                    keymaps = {
                        ["<CR>"] = {
                            action = "confirm",
                            callback = function(ctx)
                                require("snacks").api.confirm(ctx)
                                require("snacks").explorer_close() -- Close explorer after confirming
                            end,
                        }, -- Select/open file and collapse explorer
                        ["l"] = "confirm", -- Alternative key to open (like vim-vinegar)
                        ["h"] = "explorer_close", -- Close directory or go to parent
                        ["<BS>"] = "explorer_up", -- Go to parent directory
                        ["a"] = "explorer_add", -- Create new file/directory
                        ["d"] = "explorer_del", -- Delete file/directory
                        ["r"] = "explorer_rename", -- Rename file/directory
                        ["c"] = "explorer_copy", -- Copy file/directory
                        ["m"] = "explorer_move", -- Move file/directory
                        ["o"] = "explorer_open", -- Open with system application
                        ["y"] = { "explorer_yank", mode = { "n", "x" } }, -- Yank file path
                        ["p"] = "explorer_paste", -- Paste copied file
                        ["u"] = "explorer_update", -- Refresh explorer
                        ["P"] = "toggle_preview", -- Toggle preview pane
                        ["."] = "explorer_focus", -- Focus current file
                        ["I"] = "toggle_ignored", -- Toggle ignored files
                        ["H"] = "toggle_hidden", -- Toggle hidden files (though shown by default)
                        ["<C-t>"] = "open_tab", -- Open in new tab
                        ["<C-v>"] = "open_vsplit", -- Open in vertical split
                        ["<C-x>"] = "open_split", -- Open in horizontal split
                        ["q"] = "close", -- Close the picker
                        ["<C-c>"] = "tcd", -- Set current directory as working directory
                        ["<leader>/"] = "picker_grep", -- Run grep from explorer
                    },
                },
                files = {
                    -- File picker configuration
                    prompt = "Find Files> ", -- Custom prompt
                    show_hidden = true, -- Show hidden files in file picker
                    show_ignored = true, -- Show git-ignored files (e.g., .env) in file picker
                    git_untracked = true, -- Show untracked git files
                    watch = true, -- Watch for filesystem changes
                    auto_close = true, -- Close picker after confirming selection
                },
            },
        },
    },
    keys = {
        {
            "<leader>e",
            function()
                require("snacks").explorer()
            end,
            desc = "Open File Explorer",
        },
        {
            "<leader><Space>",
            function()
                require("snacks").picker.files()
            end,
            desc = "Find Files",
        },
        {
            "<leader>sg",
            function()
                require("snacks").picker.grep()
            end,
            desc = "Grep word",
        },
        {
            "<leader>sk",
            function()
                require("snacks").picker.keymaps({ layout = "ivy" })
            end,
            desc = "Search Keymaps (Snacks Picker)",
        },
        {
            "<leader>lg",
            function()
                require("snacks").lazygit()
            end,
            desc = "Lazygit",
        },
        {
            "<leader>gl",
            function()
                require("snacks").lazygit.log()
            end,
            desc = "Lazygit Logs",
        },
        {
            "<leader>bd",
            function()
                require("snacks").bufdelete()
            end,
            desc = "Delete or Close Buffer  (Confirm)",
        },

        {
            "<leader>gb",
            function()
                require("snacks").picker.git_branches({ layout = "select" })
            end,
            desc = "Pick and Switch Git Branches",
        },

        {
            "<leader>th",
            function()
                require("snacks").picker.colorschemes({ layout = "ivy" })
            end,
            desc = "Pick Color Schemes",
        },
        -- { "<leader>vh", function() require("snacks").picker.help() end, desc = "Help Pages" },
    },
}
