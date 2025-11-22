-- Native config for bash-language-server
return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  root_markers = { ".git" },
  settings = {
    bashIde = {
      enableSourceErrorDiagnostics = true,
      enableWorkspaceSymbols = true,
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
}
