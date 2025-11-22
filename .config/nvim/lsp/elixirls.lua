-- Native config for elixir-ls
return {
  cmd = { "elixir-ls" }, -- Assumes elixir-ls is in PATH
  filetypes = { "elixir", "eelixir", "heex", "surface" },
  root_markers = { "mix.exs", ".git" },
  on_attach = function(client, bufnr)
    -- Format on save for Elixir
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end,
}
