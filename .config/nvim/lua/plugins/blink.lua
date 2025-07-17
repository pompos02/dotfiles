-- local dadbod = require("plugins.dadbod")
-- lua/plugins/blink.lua
-- Clean blink.cmp configuration

return {
    -- Disable nvim-cmp if present
    {
        "hrsh7th/nvim-cmp",
        enabled = false,
    },

    -- Main blink.cmp configuration
    {
        "saghen/blink.cmp",
        version = "*",
        dependencies = {
            "rafamadriz/friendly-snippets",
            {
                "saghen/blink.compat",
                optional = true,
                opts = {},
                version = "*",
            },
        },
        event = "InsertEnter",

        opts = {
            -- Keymap presets and customizations
            keymap = {
                preset = "enter",
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-l>"] = { "select_and_accept", "fallback" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<C-q>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },

            -- Visual appearance
            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = "mono",
            },

            -- Completion behavior
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },

                -- menu = {
                --     draw = {
                --         treesitter = { "lsp" },
                --         columns = {
                --             { "label", "label_description", gap = 1 },
                --             { "kind_icon", "kind" },
                --         },
                --     },
                -- },

                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 100,
                    window = {
                        border = "rounded",
                    },
                },

                ghost_text = {
                    enabled = true, -- Set to true if you want ghost text
                },
            },

            -- Sources configuration
            sources = {
                default = { "lsp", "buffer", "snippets", "path" },
                per_filetype = {
                    sql = { "dadbod" },
                },
                providers = {
                    dadbod = { module = "vim_dadbod_completion.blink" },
                    lsp = {
                        name = "LSP",
                        module = "blink.cmp.sources.lsp",
                        score_offset = 100,
                    },

                    path = {
                        name = "Path",
                        module = "blink.cmp.sources.path",
                        score_offset = 30,
                    },

                    snippets = {
                        name = "Snippets",
                        module = "blink.cmp.sources.snippets",
                        score_offset = 80,
                    },

                    buffer = {
                        name = "Buffer",
                        module = "blink.cmp.sources.buffer",
                        score_offset = 10,
                    },
                },
            },

            -- Fuzzy matching
            fuzzy = {
                implementation = "prefer_rust_with_warning",
                use_frecency = true,
                use_proximity = true,
                sorts = { "score", "sort_text", "label" },
            },

            -- Signature help
            signature = {
                enabled = true,
            },
        },

        config = function(_, opts)
            -- Setup Tab key behavior
            if not opts.keymap["<Tab>"] then
                opts.keymap["<Tab>"] = { "select_and_accept", "fallback" }
            end

            if not opts.keymap["<S-Tab>"] then
                opts.keymap["<S-Tab>"] = { "select_prev", "fallback" }
            end

            require("blink.cmp").setup(opts)
        end,
    },
}
