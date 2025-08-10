return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
    rust_analyzer = {
      enabled = true,
      settings = {
        ["rust-analyzer"] = {
          inlayHints = { enable = false },
        },
      },
    },
    },
  },
}