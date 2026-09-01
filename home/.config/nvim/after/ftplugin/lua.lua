local function stylua_format()
    local buf = vim.api.nvim_get_current_buf()
    local view = vim.fn.winsaveview()
    local file = vim.api.nvim_buf_get_name(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local input = table.concat(lines, "\n")
    if #lines > 0 then
        input = input .. "\n"
    end
    local output = vim.fn.system({
        "stylua",
        "--search-parent-directories",
        "--stdin-filepath",
        file ~= "" and file or "stdin.lua",
        "-",
    }, input)
    if vim.v.shell_error ~= 0 then
        vim.notify(output, vim.log.levels.ERROR)
        return
    end
    local formatted = vim.split(output, "\n", { plain = true })
    if formatted[#formatted] == "" then
        table.remove(formatted, #formatted)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
    vim.fn.winrestview(view)
end
vim.keymap.set("n", "<leader>bf", stylua_format, {
    buffer = true,
    desc = "Format Lua buffer with stylua",
})
