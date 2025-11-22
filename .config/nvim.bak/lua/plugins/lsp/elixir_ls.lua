return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            elixirls = {
                cmd = { "elixir-ls" },
                filetypes = { "elixir", "eelixir", "heex", "surface" },
                on_attach = function(client, bufnr)
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end,
                    })
                end,
            },
        },
    },
}
