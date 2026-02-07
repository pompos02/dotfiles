-- vim.opt_local.commentstring = "-- %s"

vim.opt_local.foldmethod = "syntax"
vim.opt_local.foldexpr = ""

vim.opt_local.commentstring = "/* %s */"
vim.opt_local.foldtext = ""

local undo = vim.b.undo_ftplugin or ""
local reset_foldtext = "setlocal fdt<"
if undo == "" then
    vim.b.undo_ftplugin = reset_foldtext
else
    vim.b.undo_ftplugin = undo .. " | " .. reset_foldtext
end

if vim.g.plsql_fold == 1 then
    vim.opt_local.foldmethod = "syntax"
    undo = vim.b.undo_ftplugin or ""
    if undo == "" then
        vim.b.undo_ftplugin = "setlocal fdm<"
    else
        vim.b.undo_ftplugin = undo .. " | setlocal fdm<"
    end
end
