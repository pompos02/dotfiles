return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            bashls = {
                settings = {
                    bashIde = {
                        enableSourceErrorDiagnostics = true,
                        enableWorkspaceSymbols = true,
                        globPattern = "*@(.sh|.inc|.bash|.command)",
                    },
                },
            },
        },
    },
}
