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

--- comments format function

local BANNER_WIDTH = 80

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function extract_text(line)
    local s = trim(line)
    s = s:gsub("^/%*+", "")
    s = s:gsub("%*/$", "")
    s = s:gsub("^%*+", "")
    s = s:gsub("%*+$", "")
    s = trim(s)
    s = s:gsub("%s+", " ")
    return s
end

local function format_line(text)
    if text == "" then
        return string.rep("*", BANNER_WIDTH)
    end

    local max_text_len = BANNER_WIDTH - 4
    if #text > max_text_len then
        text = text:sub(1, max_text_len)
    end

    local content = " " .. text .. " "
    local stars = BANNER_WIDTH - #content
    local left = math.floor(stars / 2)
    local right = stars - left
    return string.rep("*", left) .. content .. string.rep("*", right)
end

local function format_banner_line()
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
    local text = extract_text(line)
    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { format_line(text) })
end

vim.keymap.set("n", "<leader>cf", format_banner_line, { buffer = true, desc = "Format PL/SQL banner comment line" })

undo = vim.b.undo_ftplugin or ""
local reset_comment_formatter_maps = "silent! nunmap <buffer> <leader>cf"
if undo == "" then
    vim.b.undo_ftplugin = reset_comment_formatter_maps
else
    vim.b.undo_ftplugin = undo .. " | " .. reset_comment_formatter_maps
end
