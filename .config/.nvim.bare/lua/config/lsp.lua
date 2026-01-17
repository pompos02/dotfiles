-- Global LSP configuration and initialization

-- Configure diagnostics globally (once)
vim.diagnostic.config({
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
        priority = 2000,
    },
})

-- Global LspAttach handler for gopls semantic tokens workaround
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-attach-custom", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- Gopls semantic tokens workaround
        -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        if client and client.name == "gopls" then
            if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                if semantic then
                    client.server_capabilities.semanticTokensProvider = {
                        full = true,
                        legend = {
                            tokenTypes = semantic.tokenTypes,
                            tokenModifiers = semantic.tokenModifiers,
                        },
                        range = true,
                    }
                end
            end
        end
    end,
})

-- Enable LSP servers
-- These configs are automatically loaded from ~/.config/nvim/lsp/*.lua
vim.lsp.enable({
    "basedpyright",
    "bashls",
    "clangd",
    "elixirls",
    "gopls",
    "lua_ls",
    "marksman",
    "ts_ls",
})
