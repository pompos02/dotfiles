return {
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
            { "nvim-tree/nvim-web-devicons" },
            { "pompos02/blink-cmp-plsql.nvim" },
        },
        event = "InsertEnter",
        opts = {
            -- Keymap presets and customizations
            keymap = {
                preset = "enter",
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-l>"] = { "snippet_forward", "fallback" },
                ["<C-h>"] = { "snippet_backward", "fallback" },
                ["<C-e>"] = { "cancel", "fallback" },
                ["<C-q>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },

            -- Visual appearance
            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = "mono",
            },

            cmdline = {
                enabled = false
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
                        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    end

                                    return icon .. ctx.icon_gap
                                end,

                                -- Optionally, use the highlight groups from nvim-web-devicons
                                -- You can also add the same function for `kind.highlight` if you want to
                                -- keep the highlight groups in sync with the icons.
                                highlight = function(ctx)
                                    local hl = ctx.kind_hl
                                    if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                                        if dev_icon then
                                            hl = dev_hl
                                        end
                                    end
                                    return hl
                                end,
                            },
                        },
                    },
                    auto_show = true
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
                        auto_insert = true,
                    },
                },
            },
            -- Sources configuration
            sources = {
                default = { "lsp", "buffer", "snippets", "path" },
                per_filetype = {
                    plsql = { "oravim", "buffer", "plsql" },
                },
                providers = {
                    -- dadbod = { module = "vim_dadbod_completion.blink" },
                    plsql = {
                        name = 'plsql',
                        module = 'blink-cmp-plsql',
                        score_offset = 80,
                    },
                    oravim = {
                        name = "Oravim",
                        module = "oravim.blink",
                        score_offset = 100,
                    },

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
                        score_offset = 80,
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
                enabled = false,
                window = { border = "single" },
            },
        },

        -- config = function(_, opts)
        --     -- Setup Tab key behavior
        --     if not opts.keymap["<Tab>"] then
        --         opts.keymap["<Tab>"] = { "select_and_accept", "fallback" }
        --     end
        --
        --     if not opts.keymap["<S-Tab>"] then
        --         opts.keymap["<S-Tab>"] = { "select_prev", "fallback" }
        --     end
        --
        --     require("blink.cmp").setup(opts)
        -- end,
    },
}
