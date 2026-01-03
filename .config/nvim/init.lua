-- Minimal Neovim configuration without plugin managers
-- Plugins are loaded from pack/vendor/start/ (Vim's native plugin system)

-- Set leader keys FIRST before any mappings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable fzf history; we don't want per-command files created
vim.g.fzf_history_dir = ""

-- Load core configuration modules
require("config.options")
require("config.keymaps")
require("config.lsp")

-- Load custom plugins (pure Lua, no external dependencies)
require("custom.statusline").setup()
require("custom.surround").setup()
require("local-highlight").setup()
require("treesitter-context").setup()
require("custom.git-diff")
require("diffview").setup({
    use_icons = false,
    signs = {
        fold_closed = ">",
        fold_open = "v",
        done = "x",
    },

})

-- Set shiftwidth and window borders
vim.opt.shiftwidth = 4
vim.o.winborder = "rounded"

-- Set colorscheme
vim.cmd.colorscheme("modus")
vim.opt.background = "dark"
-- Put the fzf plugin root in the runtime path when built from source
local home = vim.fn.expand("~/.fzf")

vim.opt.rtp:prepend(home)

-- Recognize common PL/SQL package file extensions
vim.filetype.add({
    extension = {
        pkb = "plsql",
        pks = "plsql",
        pls = "plsql",
        sql = "plsql",
    },
})
-- vim.filetype.add({ extension = { sql = "plsql", }, })
-- Use Windows explorer.exe for vim.ui.open (WSL/Windows friendly)
vim.ui.open = function(path)
    local job = vim.fn.jobstart({ "explorer.exe", path }, { detach = true })
    return job > 0
end


-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Treesitter setup
do
    local ok, ts = pcall(require, "nvim-treesitter")
    if not ok then
        vim.notify("nvim-treesitter not found in runtimepath", vim.log.levels.WARN)
        return
    end
    -- these table is unusded, we just showcase possible grammars
    local languages = {
        "bash", "sql", "c", "go", "cpp", "gitcommit",
        "html", "javascript", "jsdoc", "json", "jsonc", "lua", "luadoc", "luap",
        "markdown", "markdown_inline", "printf", "python", "query", "regex", "toml",
        "tsx", "typescript", "vim", "vimdoc", "xml", "yaml", "ron","diff", "git_rebase"
    }

    -- Ensure parsers/queries go to the standard data dir (prepends to runtimepath).
    ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
        highlight = { enable = true },
    })
end

-- Enable Tree-sitter r@ highlighting for gitcommit buffers
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "gitcommit" },
--     callback = function()
--         pcall(vim.treesitter.start)
--     end,
-- })
