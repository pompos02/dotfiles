vim.treesitter.start()
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.expandtab = false
vim.opt_local.list = false

-- Insert error handling snippet with <C-e>
vim.keymap.set("i", "<C-e>", function()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))

    -- Get current line to determine indentation
    local current_line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
    local indent = current_line:match("^%s*") or ""

    -- Get tab/space settings
    local use_tabs = vim.bo.expandtab == false
    local tab_size = vim.bo.tabstop
    local inner_indent = use_tabs and (indent .. "\t") or (indent .. string.rep(" ", tab_size))

    local lines = {
        indent .. "if err != nil {",
        inner_indent,
        indent .. "}",
    }
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + 2, #inner_indent + 1 })
    vim.cmd("startinsert!")
end, {
    desc = "Insert Go error handling",
    buffer = true,
    silent = true,
})
