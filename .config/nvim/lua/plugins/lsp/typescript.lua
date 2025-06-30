-- lua/plugins/lsp/typescript.lua
-- Dedicated TypeScript/TSX development configuration

return {
    -- TypeScript Language Server configuration
    typescript_servers = {
        -- TypeScript/JavaScript Language Server (vtsls - recommended)
        vtsls = {
            settings = {
                complete_function_calls = true,
                vtsls = {
                    enableMoveToFileCodeAction = true,
                    autoUseWorkspaceTsdk = true,
                    experimental = {
                        completion = {
                            enableServerSideFuzzyMatch = true,
                        },
                    },
                },
                typescript = {
                    updateImportsOnFileMove = {
                        enabled = "always",
                    },
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
                    preferences = {
                        includePackageJsonAutoImports = "auto",
                    },
                },
                javascript = {
                    updateImportsOnFileMove = {
                        enabled = "always",
                    },
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
                    preferences = {
                        includePackageJsonAutoImports = "auto",
                    },
                },
            },
        },

        -- ESLint Language Server
        eslint = {
            settings = {
                -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
                workingDirectories = { mode = "auto" },
                experimental = {
                    useFlatConfig = false,
                },
            },
        },

        -- Tailwind CSS Language Server (useful for TSX styling)
        tailwindcss = {
            root_dir = function(...)
                return require("lspconfig.util").root_pattern(".git")(...)
            end,
            settings = {
                tailwindCSS = {
                    experimental = {
                        classRegex = {
                            -- Enable Tailwind in template literals
                            "tw`([^`]*)",
                            -- Enable Tailwind in clsx/classnames calls
                            "clsx\\(([^)]*)\\)",
                            "classnames\\(([^)]*)\\)",
                            "cn\\(([^)]*)\\)",
                        },
                    },
                },
            },
        },

        -- CSS Language Server
        cssls = {
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                scss = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                less = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
            },
        },

        -- HTML Language Server
        html = {
            filetypes = { "html", "templ" },
            settings = {
                html = {
                    format = {
                        templating = true,
                        wrapLineLength = 120,
                        wrapAttributes = "auto",
                    },
                    hover = {
                        documentation = true,
                        references = true,
                    },
                },
            },
        },

        -- JSON Language Server
        jsonls = {
            settings = {
                json = {
                    format = {
                        enable = true,
                    },
                    validate = { enable = true },
                },
            },
        },
    },

    -- Mason tools for TypeScript development
    mason_tools = {
        -- Language Servers
        "vtsls", -- Modern TypeScript language server
        "eslint-lsp",
        "css-lsp",
        "html-lsp",
        "tailwindcss-language-server",
        "json-lsp",

        -- Formatters
        "prettier",
        "eslint_d", -- Faster ESLint daemon

        -- Linters (optional)
        "stylelint-lsp", -- CSS linting
    },

    -- Custom setup functions for TypeScript servers
    setup_handlers = {
        -- Custom vtsls setup with additional configuration
        vtsls = function(server, opts)
            -- Add custom keymaps for TypeScript
            opts.on_attach = function(client, bufnr)
                -- TypeScript specific keymaps
                local keymap = vim.keymap.set
                local buf_opts = { buffer = bufnr, silent = true }

                -- Organize imports
                keymap("n", "<leader>co", function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = {
                            only = { "source.organizeImports" },
                            diagnostics = {},
                        },
                    })
                end, vim.tbl_extend("force", buf_opts, { desc = "Organize Imports" }))

                -- Remove unused imports
                keymap("n", "<leader>cu", function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = {
                            only = { "source.removeUnused" },
                            diagnostics = {},
                        },
                    })
                end, vim.tbl_extend("force", buf_opts, { desc = "Remove Unused Imports" }))

                -- Add missing imports
                keymap("n", "<leader>cm", function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = {
                            only = { "source.addMissingImports" },
                            diagnostics = {},
                        },
                    })
                end, vim.tbl_extend("force", buf_opts, { desc = "Add Missing Imports" }))

                -- Fix all fixable issues
                keymap("n", "<leader>cf", function()
                    vim.lsp.buf.code_action({
                        apply = true,
                        context = {
                            only = { "source.fixAll" },
                            diagnostics = {},
                        },
                    })
                end, vim.tbl_extend("force", buf_opts, { desc = "Fix All" }))
            end

            return false -- Continue with normal setup
        end,

        -- Custom ESLint setup
        eslint = function(server, opts)
            -- Enable ESLint formatting if no other formatter is available
            opts.on_attach = function(client, bufnr)
                if client.server_capabilities.documentFormattingProvider then
                    local keymap = vim.keymap.set
                    keymap("n", "<leader>cF", function()
                        vim.lsp.buf.format({ async = true, name = "eslint" })
                    end, { buffer = bufnr, desc = "Format with ESLint" })
                end
            end

            return false -- Continue with normal setup
        end,

        -- Custom JSON setup with schemastore
        jsonls = function(server, opts)
            local ok, schemastore = pcall(require, "schemastore")
            if ok then
                opts.settings.json.schemas = schemastore.json.schemas()
            end
            return false -- Continue with normal setup
        end,
    },

    -- File type associations for better detection
    filetypes = {
        typescript = { "typescript", "typescriptreact", "typescript.tsx" },
        javascript = { "javascript", "javascriptreact", "javascript.jsx" },
        json = { "json", "jsonc" },
        css = { "css", "scss", "sass", "less" },
        html = { "html", "htmldjango", "htmljinja" },
    },
}
