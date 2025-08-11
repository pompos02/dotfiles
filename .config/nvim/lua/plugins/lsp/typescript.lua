return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
            --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
            tsserver = {
                enabled = false,
            },
            ts_ls = {
                enabled = true,
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "javascript.jsx",
                    "typescript",
                    "typescriptreact",
                    "typescript.tsx",
                },
                settings = {
                    typescript = {
                        updateImportsOnFileMove = { enabled = "always" },
                        suggest = {
                            completeFunctionCalls = true,
                        },
                        inlayHints = {
                            enumMemberValues = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                            parameterNames = { enabled = "literals" },
                            parameterTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            variableTypes = { enabled = false },
                        },
                    },
                },
            },
            vtsls = {
                enabled = false,
            },
        },
        setup = {
            --- @deprecated -- tsserver renamed to ts_ls but not yet released, so keep this for now
            --- the proper approach is to check the nvim-lspconfig release version when it's released to determine the server name dynamically
            tsserver = function()
                -- disable tsserver
                return true
            end,
            ts_ls = function(_, opts)
                -- copy typescript settings to javascript
                opts.settings.javascript =
                    vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
            end,
            vtsls = function()
                -- disable vtsls
                return true
            end,
        },
    },
}
