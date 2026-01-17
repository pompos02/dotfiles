"" Leaders first
let mapleader = " "
let maplocalleader = "\\"

set background=dark
set colorscheme default
"
" Enable syntax and filetype detection/plugins/indent
syntax enable
filetype plugin indent on

" Options
set undodir=~/.vim/undo
set ttimeoutlen=50
set hlsearch
set incsearch
set noswapfile
set number
set relativenumber
set shiftround
set completeopt=menu,menuone,noselect
set path+=**
set conceallevel=2
set confirm
set expandtab
if exists('+inccommand')
    set inccommand=nosplit
endif
set linebreak
set mouse=a
set noruler
set scrolloff=10
set sessionoptions=buffers,curdir,tabpages,winsize,help,folds
set sidescrolloff=8
set signcolumn=yes
set smartcase
set ignorecase
set smartindent
set spelllang=en
set splitbelow
if exists('+splitkeep')
    set splitkeep=screen
endif
set splitright

set termguicolors

set undofile
set undolevels=10000
set updatetime=200
set virtualedit=block
set wildmode=longest:full,full
set winminwidth=5
set nowrap
set cursorline
set showtabline=1
set guicursor=n-v-c-sm:block,i-ci-ve:block-blinkwait500-blinkoff200-blinkon200,r-cr-o:hor20
let &colorcolumn = '80'
set shiftwidth=4
set laststatus=2
if empty($SSH_TTY)
    set clipboard=unnamedplus
endif


" Keymaps -------------------------------------------------------------
nnoremap <silent> <C-c> :nohlsearch<CR>
nnoremap <expr> <Esc> v:hlsearch ? ":nohlsearch\<CR>" : "\<Esc>"

" Centered scrolling / motions
nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz
nnoremap <silent> } }zz
nnoremap <silent> { {zz
nnoremap <expr> j v:count == 0 ? "gj" : "j"
nnoremap <expr> k v:count == 0 ? "gk" : "k"
xnoremap <expr> j v:count == 0 ? "gj" : "j"
xnoremap <expr> k v:count == 0 ? "gk" : "k"
nnoremap <expr> <Down> v:count == 0 ? "gj" : "j"
nnoremap <expr> <Up> v:count == 0 ? "gk" : "k"
xnoremap <expr> <Down> v:count == 0 ? "gj" : "j"
xnoremap <expr> <Up> v:count == 0 ? "gk" : "k"

" Undo breakpoints in insert mode
inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ; ;<C-g>u

" Quickfix navigation
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>

" File explorer (netrw)
nnoremap <silent> <leader>e :Explore<CR>
nnoremap <silent> <leader>E :execute 'Explore ' . getcwd()<CR>

" Statusline ---------------------------------------------------------
function! s:GitBranch() abort
    let l:out = systemlist('git branch --show-current 2>/dev/null')
    if len(l:out) > 0 && !empty(l:out[0])
        return '[' . l:out[0] . '] '
    endif
    return ''
endfunction

function! Statusline() abort
    let l:fname = expand('%:.')
    if empty(l:fname)
        let l:fname = '[No Name]'
    endif
    let l:mod = &modified ? '[+]' : ''
    return s:GitBranch() . l:fname . l:mod . '%=' . strftime('%H:%M')
endfunction
set statusline=%!Statusline()

function! s:StatuslineColors() abort
    let l:n_fg = synIDattr(hlID('Normal'), 'fg#')
    let l:n_bg = synIDattr(hlID('Normal'), 'bg#')
    let l:cl_bg = hlexists('CursorLine') ? synIDattr(hlID('CursorLine'), 'bg#') : ''
    let l:bg = empty(l:cl_bg) ? (empty(l:n_bg) ? 'NONE' : l:n_bg) : l:cl_bg
    let l:fg = empty(l:n_fg) ? 'NONE' : l:n_fg
    execute 'hi StatusLine guibg=' . l:bg . ' guifg=' . l:fg
    execute 'hi StatusLineNC guibg=' . l:bg . ' guifg=' . l:fg
endfunction

augroup CustomStatusline
    autocmd!
    autocmd BufEnter,BufWritePost,WinEnter,ColorScheme * redrawstatus | call s:StatuslineColors()
augroup END
call s:StatuslineColors()

" Filetype-specific settings ----------------------------------------
augroup FiletypeSettings
    autocmd!
    autocmd FileType c setlocal shiftwidth=4
augroup END
