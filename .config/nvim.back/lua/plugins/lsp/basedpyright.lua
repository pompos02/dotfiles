return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            basedpyright = {
                settings = {
                    basedpyright = {
                        -- Disable all formatting and linting (handled by ruff via none-ls)
                        disableOrganizeImports = true,
                        disableLanguageServices = false,
                        analysis = {
                            -- Type checking settings
                            typeCheckingMode = "basic",
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            autoImportCompletions = true,
                            diagnosticMode = "openFilesOnly",
                            inlayHints = {
                                variableTypes = false,
                                callArgumentNames = false,
                            },
                            -- Disable linting features (handled by ruff)
                            diagnosticSeverityOverrides = {
                                reportUnusedImport = "none",
                                reportUnusedVariable = "none",
                                reportUnusedClass = "none",
                                reportUnusedFunction = "none",
                            },
                        },
                    },
                },
            },
        },
    },
}
