return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason.nvim",
        },
        opts = {
            -- Global diagnostics configuration
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "E",
                        [vim.diagnostic.severity.WARN] = "W",
                        [vim.diagnostic.severity.INFO] = "I",
                        [vim.diagnostic.severity.HINT] = "H",
                    },
                },
            },
            -- Global LSP settings
            inlay_hints = {
                enabled = true,
            },
            -- Codelens
            codelens = {
                enabled = false,
            },
            -- Document highlighting
            document_highlight = {
                enabled = true,
            },
            -- Capabilities
            capabilities = {},
            -- Format on save
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            -- LSP servers will be configured here or inside the /lsp directory
            servers = {},
        },
        config = function(_, opts)
            -- Setup diagnostics
            vim.diagnostic.config(opts.diagnostics)

            -- Setup servers
            for server, config in pairs(opts.servers) do
                -- Skip servers that are explicitly disabled
                if config.enabled == false then
                    goto continue
                end
                vim.lsp.config(server, config)
                vim.lsp.enable(server)
                ::continue::
            end
        end,
    },
}
