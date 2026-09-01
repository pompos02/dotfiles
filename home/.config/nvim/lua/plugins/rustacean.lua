return {
    "mrcjkb/rustaceanvim",
    version = "^7",
    lazy = false,

    init = function()
        vim.g.rustaceanvim = {
            server = {
                on_attach = function(client, bufnr)
                    client.server_capabilities.semanticTokensProvider = nil
                end,
            },
        }
    end,
}
