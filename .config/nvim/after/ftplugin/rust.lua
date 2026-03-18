vim.cmd("compiler cargo")

local bufname = vim.api.nvim_buf_get_name(0)
local bufdir = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
local manifest = vim.fs.find("Cargo.toml", { path = bufdir, upward = true })[1]

local function maker()
    if manifest then
        return "cargo run --manifest-path " .. vim.fn.fnameescape(manifest)
    end

    return "cargo run"
end

if manifest then
    vim.opt_local.makeprg = maker()
else
    vim.opt_local.makeprg = maker()
end

local undo = vim.b.undo_ftplugin and (vim.b.undo_ftplugin .. "|") or ""
vim.b.undo_ftplugin = undo .. "setlocal makeprg< errorformat<"
