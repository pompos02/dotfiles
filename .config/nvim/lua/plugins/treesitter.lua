return {
    "nvim-treesitter/nvim-treesitter",
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
        require("nvim-treesitter.configs").setup({
            highlight = { enable = true },
            indent = { enable = true },
            ensure_installed = {
                "bash",
                "sql",
                "c",
                "cpp",
                "diff",
                "elixir",
                "heex",
                "eex",
                "go",
                "gomod",
                "gowork",
                "gosum",
                "html",
                "javascript",
                "jsdoc",
                "json",
                "jsonc",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "make",
                "printf",
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
                "ron",
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true, -- Automatically jump forward to textobj
                    keymaps = {
                        -- Functions
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        -- Classes
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        -- quotes
                        ["aq"] = "@quote.outer",
                        ["iq"] = "@quote.inner",
                        -- Conditionals
                        ["ai"] = "@conditional.outer",
                        ["ii"] = "@conditional.inner",
                        -- Loops
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                        -- Blocks
                        ["ab"] = "@block.outer",
                        ["ib"] = "@block.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                        ["]a"] = "@parameter.inner",
                    },
                    goto_next_end = {
                        ["]F"] = "@function.outer",
                        ["]C"] = "@class.outer",
                        ["]A"] = "@parameter.inner",
                    },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                        ["[a"] = "@parameter.inner",
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer",
                        ["[C"] = "@class.outer",
                        ["[A"] = "@parameter.inner",
                    },
                },
            },
        })
    end,
}
