local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.shiftround = true -- Round indent
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
-- opt.completeopt = "menu,menuone"
opt.path:append("**") -- Enable recursive file search with :find
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
opt.relativenumber = true                               -- Relative line numbers
opt.ruler = false                                       -- Disable the default ruler
opt.scrolloff = 10                                       -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.sidescrolloff = 8                                   -- Columns of context
opt.signcolumn = "yes"                                  -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true                                    -- Don't ignore case with capitals
opt.ignorecase = true                                   -- Case insesive search
opt.smartindent = true                                  -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true                                   -- Put new windows below current
opt.equalalways = true
opt.splitkeep = "screen"
opt.splitright = true                                   -- Put new windows right of current
opt.tabstop = 2                                         -- Number of spaces tabs count for
-- opt.listchars = { trail = "." }
opt.termguicolors = true                                -- True color support
opt.undofile = true
opt.undolevels = 10000

opt.updatetime = 750                                                                            -- Save swap file and trigger CursorHold
opt.virtualedit = "block"                                                                       -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full"                                                              -- Command-line completion mode
opt.winminwidth = 5                                                                             -- Minimum window width
opt.wrap = false                                                                                -- Disable line wrap
opt.cursorline = true                                                                           -- Highlight the line where the cursor is located
-- opt.fillchars:append({ eob = " " })                                                             -- Remove ~ from empty lines
opt.showtabline = 1                                                                             -- Never show tabline
opt.guicursor =
"n-v-c-sm:block,i-ci-ve:block-blinkwait500-blinkoff200-blinkon200,r-cr-o:hor20"                 -- Use blinking block cursor in insert mode
vim.opt.colorcolumn = "80"
vim.opt.grepprg = "rg --vimgrep -uu"
