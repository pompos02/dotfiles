-- Native config for clangd
return {
  cmd = {
    "clangd",
    "--query-driver=/usr/bin/g++",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  root_markers = { ".clangd", "compile_commands.json", ".git" },
}

