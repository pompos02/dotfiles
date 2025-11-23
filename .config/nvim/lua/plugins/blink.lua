return {
    -- Main blink.cmp configuration
    {
        "saghen/blink.cmp",
        version = "*",
        dependencies = {
            "rafamadriz/friendly-snippets",
            { "onsails/lspkind.nvim" },
            -- { "nvim-tree/nvim-web-devicons" },
        },
        event = "InsertEnter",
        opts = {
            -- Keymap presets and customizations
            keymap = {
                preset = "enter",
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-l>"] = { "snippet_forward", "fallback" }, -- Add this for snippet navigation
                ["<C-h>"] = { "snippet_backward", "fallback" },
                ["<C-e>"] = { "cancel", "fallback" },
                ["<C-q>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },


            -- Completion behavior
            completion = {
                accept = {
                        auto_brackets = {
                            enabled = true,
                        },
                },

                menu = {
                    draw = {
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    else
                                        icon = require("lspkind").symbolic(ctx.kind, {
                                            mode = "symbol",
                                        })
                                    end

                                    return icon .. ctx.icon_gap
                                end,
                            },
                        },
                    },
                },

                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 100,
                    window = {
                        border = "rounded",
                    },
                },

                ghost_text = {
                    enabled = false, -- Set to true if you want ghost text
                },

                list = {
                    selection = {
                        preselect = false,
                        auto_insert = false,
                    },
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
                        opts = {
                            friendly_snippets = true,
                            search_paths = { vim.fn.stdpath("config") .. "/snippets" },
                        },
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
                frequency = {
                    enabled = true,
                },
                use_proximity = true,
                sorts = { "score", "sort_text", "label" },
            },
            -- Signature help
            signature = {
                enabled = true,
                window = { border = "single" },
            },
        },
    },
}
