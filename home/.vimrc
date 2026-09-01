"" Leaders first
let mapleader = " "
let maplocalleader = "\\"

set background=dark
"colorscheme elflord
set t_Co=16
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
set shiftround
set completeopt=menu,menuone,noselect
set path+=**
set confirm
set expandtab
set mouse=a
set ruler
set scrolloff=10
set sessionoptions=buffers,curdir,tabpages,winsize,help,folds
set sidescrolloff=8
set smartcase
set ignorecase
set smartindent
set spelllang=en
set splitbelow
if exists('+splitkeep')
    set splitkeep=screen
endif
set splitright

set undofile
set undolevels=10000
set updatetime=200
set virtualedit=block
set wildmode=longest:full,full
set wildmenu
set winminwidth=5
set nowrap
set cursorline
set showtabline=1
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

" Filetype-specific settings ----------------------------------------
augroup FiletypeSettings
    autocmd!
    autocmd FileType c setlocal shiftwidth=4
augroup END
