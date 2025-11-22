-- Native config for basedpyright
return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      disableLanguageServices = false,
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        autoImportCompletions = true,
        diagnosticMode = "openFilesOnly",
        inlayHints = {
          variableTypes = false,
          callArgumentNames = false,
        },
        diagnosticSeverityOverrides = {
          reportUnusedImport = "none",
          reportUnusedVariable = "none",
          reportUnusedClass = "none",
          reportUnusedFunction = "none",
        },
      },
    },
  },
}
