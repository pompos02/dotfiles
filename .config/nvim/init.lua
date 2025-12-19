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
require("config.markdown").setup()

-- Load custom plugins (pure Lua, no external dependencies)
require("custom.statusline").setup()
require("custom.surround").setup()
require("local-highlight").setup()
require'treesitter-context'.setup()

-- Set shiftwidth and window borders
vim.opt.shiftwidth = 4
vim.o.winborder = "rounded"

-- Set colorscheme
-- vim.cmd.colorscheme("misirlou-lightstrong")
vim.cmd.colorscheme("misirlou-resu")

-- Put the fzf plugin root in the runtime path when built from source
local home = vim.fn.expand("~/.fzf")
-- local home = vim.fn.expand("~/.local/share/nvim")

vim.opt.rtp:prepend(home)

-- Recognize common PL/SQL package file extensions
vim.filetype.add({
    extension = {
        pkb = "plsql",
        pks = "plsql",
        pls = "plsql",
    },
})

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

    local parser_config = require("nvim-treesitter.parsers")
    parser_config.plsql = parser_config.plsql or {}
    parser_config.plsql.install_info = parser_config.plsql.install_info or {
        path = "/home/karavellas/projects/opensource/tree-sitter-plsql",
        files = { "src/parser.c" },
    } -- parser already built locally; keep path for optional TSInstall
    parser_config.plsql.filetype = "plsql"
    parser_config.plsql.used_by = { "sql" }
    pcall(vim.treesitter.language.register, "plsql", "plsql")
    pcall(vim.treesitter.language.register, "plsql", "sql")

    local languages = {
        "bash", "sql", "plsql", "c", "go",
        "html", "javascript", "jsdoc", "json", "jsonc", "lua", "luadoc", "luap",
        "markdown", "markdown_inline", "printf", "python", "query", "regex", "toml",
        "tsx", "typescript", "vim", "vimdoc", "xml", "yaml", "ron",
    }

    -- Install any missing parsers asynchronously (no-op for already installed ones).
    local installed = ts.get_installed()
    local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
    end, languages)
    if #missing > 0 then
        ts.install(missing, { summary = true })
    end

    -- Ensure parsers/queries go to the standard data dir (prepends to runtimepath).
    ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

    -- Enable Treesitter highlight and indent when entering a buffer.
    local group = vim.api.nvim_create_augroup("treesitter_enable", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable Treesitter features",
        group = group,
        callback = function(args)
            pcall(vim.treesitter.start, args.buf)
            local ft = vim.bo[args.buf].filetype
            if ft == "sql" or ft == "plsql" then
                return -- keep Vim's default SQL/PLSQL indent behavior
            end
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end
