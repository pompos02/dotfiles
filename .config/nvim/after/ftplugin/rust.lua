vim.cmd("compiler cargo")

local bufname = vim.api.nvim_buf_get_name(0)
local bufdir = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
local manifest = vim.fs.find("Cargo.toml", { path = bufdir, upward = true })[1]

if manifest then
    vim.opt_local.makeprg = "cargo build --manifest-path " .. vim.fn.fnameescape(manifest)
else
    vim.opt_local.makeprg = "cargo build"
end

local undo = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. "|") or ""
vim.b.undo_ftplugin = undo .. "setlocal makeprg< errorformat<"
