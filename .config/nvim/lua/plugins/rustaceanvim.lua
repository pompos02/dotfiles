return {
    {
        "mrcjkb/rustaceanvim",
        version = "^6",  -- Recommended to pin to a major version
        lazy = false,    -- This plugin is already lazy by design
        ft = { "rust" }, -- Load only for Rust files
        config = function()
            vim.g.rustaceanvim = {
                -- LSP configuration
                server = {
                    on_attach = function(client, bufnr)
                        -- Enable inlay hints
                        if client.server_capabilities.inlayHintProvider then
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end

                        -- Essential keymaps
                        local opts = { buffer = bufnr, silent = true }

                        -- Hover actions (override default K behavior)
                        vim.keymap.set("n", "K", function()
                            vim.cmd.RustLsp({ "hover", "actions" })
                        end, vim.tbl_extend("force", opts, { desc = "Rust hover actions" }))

                        -- Code actions (supports rust-analyzer's grouped actions)
                        vim.keymap.set("n", "<leader>ca", function()
                            vim.cmd.RustLsp("codeAction")
                        end, vim.tbl_extend("force", opts, { desc = "Code action" }))
                    end,

                    -- Use clippy for better linting
                    default_settings = {
                        ["rust-analyzer"] = {
                            check = {
                                command = "clippy",
                            },
                        },
                    },
                },
            }
        end,
    },
}
