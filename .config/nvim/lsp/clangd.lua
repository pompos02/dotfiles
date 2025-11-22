-- Native config for clangd
return {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = { ".clangd", "compile_commands.json", ".git" },
}
