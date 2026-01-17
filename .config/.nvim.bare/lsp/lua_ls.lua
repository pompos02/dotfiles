-- Native config for lua-language-server
return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },

      workspace = {
        checkThirdParty = false,

        library = {
          vim.env.VIMRUNTIME,                                       -- Neovim runtime
          vim.fn.expand("~/.local/share/nvim/nvim-api/runtime/lua") -- Neovim API types
        },
      },

      diagnostics = {
        globals = { "vim" },
      },

      codeLens = {
        enable = true,
      },

      completion = {
        callSnippet = "Replace",
      },

      doc = {
        privateName = { "^_" },
      },

      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
    },
  },
}

