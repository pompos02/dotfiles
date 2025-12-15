-- Ensure true color
vim.o.termguicolors = true

-- Function: remove bold from ALL highlight groups
local function disable_bold_everywhere()
  for _, group in ipairs(vim.fn.getcompletion("", "highlight")) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group })
    if ok and hl.bold then
      vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", hl, { bold = false }))
    end
  end

  -- Treesitter (global)
  vim.api.nvim_set_hl(0, "@markup.strong", { bold = false })
  vim.api.nvim_set_hl(0, "@markup.heading", { bold = false })
end

-- Run on startup and after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = disable_bold_everywhere,
})
disable_bold_everywhere()

-- Re-enable bold ONLY for Markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Classic markdown
    local groups = {
      "markdownBold",
      "markdownBoldDelimiter",
      "markdownBoldItalic",
      "markdownHeading",
      "markdownH1",
      "markdownH2",
      "markdownH3",
      "markdownH4",
      "markdownH5",
      "markdownH6",
    }

    for _, g in ipairs(groups) do
      vim.api.nvim_set_hl(0, g, { bold = true })
    end

    -- Treesitter markdown
    vim.api.nvim_set_hl(0, "@markup.strong", { bold = true })
    vim.api.nvim_set_hl(0, "@markup.heading", { bold = true })
  end,
})

