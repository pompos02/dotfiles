return {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.3",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
        { "<c-space>", desc = "Increment Selection" },
        { "<bs>",      desc = "Decrement Selection", mode = "x" },
    },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        -- vim.treesitter.language.register("sql", "plsql")
        require("nvim-treesitter.configs").setup({
            highlight = {
                enable = true,
                disable = { "markdown", "markdown_inline" },
            },
            indent = { enable = true },
            ensure_installed = {
                "bash",
                "sql",
                "c",
                "diff",
                "gitcommit",
                "go",
                "gomod",
                "gowork",
                "gosum",
                "html",
                "javascript",
                "json",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "regex",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "xml",
                "yaml",
                "rust",
            },
            incremental_selection = { enable = false },
        })

        textobjects.setup({
            select = {
                lookahead = true,
                include_surrounding_whitespace = true,
                selection_modes = {
                    ["@parameter.outer"] = "v",
                    ["@function.outer"] = "V",
                    ["@class.outer"] = "V",
                },
            },
            move = {
                set_jumps = true,
            },
        })

        local select_modes = { "x", "o" }
        local move_modes = { "n", "x", "o" }

        vim.keymap.set(select_modes, "af", function()
            select.select_textobject("@function.outer", "textobjects")
        end, { desc = "Select around function" })
        vim.keymap.set(select_modes, "if", function()
            select.select_textobject("@function.inner", "textobjects")
        end, { desc = "Select inside function" })
        vim.keymap.set(select_modes, "ac", function()
            select.select_textobject("@class.outer", "textobjects")
        end, { desc = "Select around class" })
        vim.keymap.set(select_modes, "ic", function()
            select.select_textobject("@class.inner", "textobjects")
        end, { desc = "Select inside class" })
        vim.keymap.set(select_modes, "ai", function()
            select.select_textobject("@conditional.outer", "textobjects")
        end, { desc = "Select around conditional" })
        vim.keymap.set(select_modes, "ii", function()
            select.select_textobject("@conditional.inner", "textobjects")
        end, { desc = "Select inside conditional" })
        vim.keymap.set(select_modes, "al", function()
            select.select_textobject("@loop.outer", "textobjects")
        end, { desc = "Select around loop" })
        vim.keymap.set(select_modes, "il", function()
            select.select_textobject("@loop.inner", "textobjects")
        end, { desc = "Select inside loop" })

        vim.keymap.set(move_modes, "]f", function()
            move.goto_next_start("@function.outer", "textobjects")
        end, { desc = "Next function start" })
        vim.keymap.set(move_modes, "]F", function()
            move.goto_next_end("@function.outer", "textobjects")
        end, { desc = "Next function end" })
        vim.keymap.set(move_modes, "[f", function()
            move.goto_previous_start("@function.outer", "textobjects")
        end, { desc = "Previous function start" })
        vim.keymap.set(move_modes, "[F", function()
            move.goto_previous_end("@function.outer", "textobjects")
        end, { desc = "Previous function end" })

        vim.keymap.set(move_modes, "]i", function()
            move.goto_next("@conditional.outer", "textobjects")
        end, { desc = "Next conditional" })
        vim.keymap.set(move_modes, "[i", function()
            move.goto_previous("@conditional.outer", "textobjects")
        end, { desc = "Previous conditional" })
        vim.keymap.set(move_modes, "]l", function()
            move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
        end, { desc = "Next loop" })
        vim.keymap.set(move_modes, "[l", function()
            move.goto_previous_start({ "@loop.inner", "@loop.outer" }, "textobjects")
        end, { desc = "Previous loop" })
    end,
}
