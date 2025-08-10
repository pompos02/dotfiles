return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
    },
    opts = {
      -- Global diagnostics configuration
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN] = "󰀪",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰌶",
          },
        },
      },
      -- Global LSP settings
      inlay_hints = {
        enabled = true,
      },
      -- Codelens
      codelens = {
        enabled = false,
      },
      -- Document highlighting
      document_highlight = {
        enabled = true,
      },
      -- Capabilities
      capabilities = {},
      -- Format on save
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      -- LSP servers will be configured here
      servers = {},
    },
    config = function(_, opts)
      -- Setup diagnostics
      vim.diagnostic.config(opts.diagnostics)

      -- Setup servers
      local lspconfig = require("lspconfig")
      for server, config in pairs(opts.servers) do
        lspconfig[server].setup(config)
      end
    end,
  },
}
