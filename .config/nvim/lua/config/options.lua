local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.shiftround = true -- Round indent
vim.opt.swapfile = false
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,longest"
opt.path:append("**")                                   -- Enable recursive file search with :find
opt.conceallevel = 2                                    -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true                                      -- Confirm to save changes before exiting modified buffer
opt.expandtab = true                                    -- Use spaces instead of tabs
opt.inccommand = "nosplit"                              -- preview incremental substitute
opt.jumpoptions = "view"
opt.laststatus = 3                                      -- global statusline
opt.linebreak = true                                    -- Wrap lines at convenient points
opt.list = true                                         -- Show some invisible characters (tabs...
opt.mouse = "a"                                         -- Enable mouse mode
opt.pumblend = 0                                        -- Popup blend
opt.pumheight = 10                                      -- Maximum number of entries in a popup
opt.ruler = false                                       -- Disable the default ruler
opt.scrolloff = 10                                      -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.sidescrolloff = 8                                   -- Columns of context
opt.signcolumn = "yes:1"
-- vim.opt.statuscolumn = "%=%l %s"
opt.smartcase = true   -- Don't ignore case with capitals
opt.ignorecase = true  -- Case insesive search
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true  -- Put new windows below current
opt.equalalways = true
opt.splitkeep = "screen"
opt.splitright = true    -- Put new windows right of current
opt.tabstop = 2          -- Number of spaces tabs count for
-- opt.listchars = { trail = "." }
opt.termguicolors = true -- True color support
opt.undofile = true
opt.undolevels = 10000

opt.updatetime = 750               -- Save swap file and trigger CursorHold
opt.virtualedit =
"block"                            -- Allow cursor to move where there is no text in visual block mode
opt.wildmode =
"longest:full,full"                -- Command-line completion mode
opt.winminwidth = 5                -- Minimum window width
opt.wrap = false                   -- Disable line wrap
opt.cursorline = true              -- Highlight the line where the cursor is located
-- opt.fillchars:append({ eob = " " })                                                             -- Remove ~ from empty lines
opt.showtabline = 1                -- Never show tabline
-- opt.guicursor = "n-v-c-sm:block,i-ci-ve:block-blinkwait500-blinkoff200-blinkon200,r-cr-o:hor20"                 -- Use blinking block cursor in insert mode
opt.colorcolumn = "80"
opt.grepprg = "rg --vimgrep -uu --glob '!.git/**' --glob '!**/.git/**'"
opt.showbreak = "↳ "
opt.wildmenu = true

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

_G.custom_fold_text = function()
    local start_line = vim.v.foldstart
    local end_line = vim.v.foldend
    local line_count = end_line - start_line + 1

    -- calculate neseted folds withing this range
    local nested_folds = 0
    for i = start_line + 1, end_line do
        if vim.fn.foldlevel(i) > vim.fn.foldlevel(i - 1) then
            nested_folds = nested_folds + 1
        end
    end

    local line_text = vim.fn.getline(start_line)
    local win_width = vim.api.nvim_win_get_width(0)

    local fold_info = string.format("%df", nested_folds)
    local line_info = string.format("%dl", line_count)
    local suffix = fold_info .. "|" .. line_info

    local padding = win_width - #line_text - #suffix - 10
    if padding < 1 then padding = 1 end

    return "[" .. suffix .. "] >> " .. line_text .. string.rep(" ", padding)
end

vim.opt.foldtext = "v:lua.custom_fold_text()"

-- force syntax native syntax hilighting in markdown
vim.g.markdown_fenced_languages = {
    "bash=sh",
    "c",
    "css",
    "diff",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "python",
    "rust",
    "sh",
    "sql=plsql",
    "plsql=plsql",
    "toml",
    "typescript",
    "vim",
    "xml",
    "yaml",
}
