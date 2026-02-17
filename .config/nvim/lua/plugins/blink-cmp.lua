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
                    border = "none",
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
                    plsql = { "oravim", "buffer", "plsql", "snippets" },
                },
                providers = {
                    -- dadbod = { module = "vim_dadbod_completion.blink" },
                    plsql = {
                        name = 'plsql',
                        module = 'blink-cmp-plsql',
                        score_offset = 81,
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
                        score_offset = 80,
                    },

                    snippets = {
                        name = "Snippets",
                        module = "blink.cmp.sources.snippets",
                        score_offset = 79,
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

        -- remove duplicates from the sources
        config = function(_, opts)

            require("blink.cmp").setup(opts)

            local list = require("blink.cmp.completion.list")
            local original_fuzzy = list.fuzzy
            local priority = {
                lsp = 1,
                oravim = 2,
                plsql = 3,
                snippets = 4,
                buffer = 5,
                path = 6,
            }

            list.fuzzy = function(context, items_by_source)
                local items = original_fuzzy(context, items_by_source)
                local best_by_label = {}

                for _, item in ipairs(items) do
                    local label = item.label or ""
                    local source_id = item.source_id or ""
                    local score = priority[source_id] or 100
                    local current = best_by_label[label]
                    if not current or score < current.score then
                        best_by_label[label] = { item = item, score = score }
                    end
                end

                local deduped = {}
                for _, item in ipairs(items) do
                    local label = item.label or ""
                    local best = best_by_label[label]
                    if best and best.item == item then
                        table.insert(deduped, item)
                    end
                end

                return deduped
            end
        end,
    },
}
