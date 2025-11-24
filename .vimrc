"" Leaders first
let mapleader = " "
let maplocalleader = "\\"

colorscheme lunaperche


" Disable fzf history files
let g:fzf_history_dir = ""

" Enable syntax and filetype detection/plugins/indent
syntax enable
filetype plugin indent on

" Options
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
set updatetime=750
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

" Move visual lines
xnoremap K :move '<-2<CR>gv=gv
xnoremap J :move '>+1<CR>gv=gv

" Delete without yanking
nnoremap <silent> <leader>d "_d
xnoremap <silent> <leader>d "_d

" Paste without overwriting the default register
xnoremap <silent> <leader>p "_dP

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

" Better indenting
xnoremap < <gv
xnoremap > >gv

" Quickfix navigation
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>

" File explorer (netrw)
nnoremap <silent> <leader>e :Explore<CR>
nnoremap <silent> <leader>E :execute 'Explore ' . getcwd()<CR>

" Vimgrep helpers
function! s:VimgrepSelection() abort
  normal! "vy
  let text = escape(getreg('v'), '/')
  call feedkeys(":vimgrep /" . text . "/j **/*", 'n')
endfunction
xnoremap <silent> gs :<C-u>call <SID>VimgrepSelection()<CR>

function! s:VimgrepCword() abort
  let word = escape(expand('<cword>'), '/')
  call feedkeys(":vimgrep /" . word . "/j **/*", 'n')
endfunction
nnoremap <silent> gw :call <SID>VimgrepCword()<CR>

" Pickers (fzf) -------------------------------------------------------
function! s:EnsureFzf() abort
  if exists('*fzf#run') && exists('*fzf#wrap')
    return 1
  endif
  echoerr "fzf.vim is not available on runtimepath"
  return 0
endfunction

function! s:JumpFileLine(line) abort
  let l:clean = substitute(a:line, '\e\\[[0-9;]*m', '', 'g')
  let l:match = matchlist(l:clean, '^\([^:]\+\):\(\d\+\)')
  if len(l:match) >= 3
    execute 'edit' fnameescape(l:match[1])
    execute l:match[2]
    normal! zz
  endif
endfunction

function! s:PickerFiles() abort
  if !s:EnsureFzf() | return | endif
  if executable('fd')
    let l:cmd = "fd --type f --hidden --exclude .git"
  else
    let l:cmd = "find . -type f -not -path '*/.git/*' 2>/dev/null"
  endif
  let l:spec = {'source': l:cmd, 'sink': 'edit', 'options': ['--prompt=Files> ']}
  call fzf#run(fzf#wrap('files', l:spec, 0))
endfunction

function! s:PickerLiveGrep(...) abort
  if !s:EnsureFzf() | return | endif
  let l:query = a:0 ? a:1 : ''
  let l:has_rg = executable('rg')
  function! s:GrepReload(q) closure abort
    if l:has_rg
      return "rg --line-number --hidden --glob '!.git/**' --color=never -- " . shellescape(a:q)
    endif
    return "grep --color=never -rn --include='*' --exclude-dir=.git " . shellescape(a:q) . " . 2>/dev/null"
  endfunction
  let l:init = empty(l:query) ? "printf ''" : s:GrepReload(l:query)
  let l:opts = [
        \ '--ansi',
        \ '--prompt=Grep> ',
        \ '--delimiter=:',
        \ '--preview',
        \ l:has_rg
        \   ? "rg --color=always --line-number --hidden --glob '!.git/**' --context 5 -- {q} {1}"
        \   : "grep --color=always -n -C4 --include='*' --exclude-dir=.git -- {q} {1}",
        \ '--preview-window=right:60%',
        \ '--bind', 'change:reload:'.s:GrepReload('{q}'),
        \ '--phony'
        \ ]
  if !empty(l:query)
    call add(l:opts, '--query='.l:query)
  endif
  let l:spec = {'source': l:init, 'sink*': function('s:JumpFileLine'), 'options': l:opts}
  call fzf#run(fzf#wrap('live_grep', l:spec, 0))
endfunction

function! s:PickerBuffers() abort
  if !s:EnsureFzf() | return | endif
  let l:items = []
  for buf in getbufinfo({'bufloaded': 1})
    if !empty(buf.name)
      let l:display = fnamemodify(buf.name, ':~:.')
      let l:modified = buf.changed ? ' [+]' : ''
      call add(l:items, printf('%d: %s%s', buf.bufnr, l:display, l:modified))
    endif
  endfor
  if empty(l:items)
    echo "No buffers to show"
    return
  endif
  let l:spec = {'source': l:items, 'sink': {line -> execute('buffer ' . matchstr(line, '^[0-9]\\+'))}, 'options': "--prompt=Buffers> "}
  call fzf#run(fzf#wrap('buffers', l:spec, 0))
endfunction

function! s:PickerHelp() abort
  if !s:EnsureFzf() | return | endif
  let l:tags = []
  for file in split(globpath(&rtp, 'doc/tags'), '\n')
    if empty(file) | continue | endif
    for line in readfile(file)
      let l:tag = matchstr(line, '^[^\t]\+')
      if !empty(l:tag)
        call add(l:tags, l:tag)
      endif
    endfor
  endfor
  if empty(l:tags)
    echo "No help tags found"
    return
  endif
  let l:spec = {'source': l:tags, 'sink': {tag -> execute('help ' . tag)}, 'options': "--prompt='Help>' "}
  call fzf#run(fzf#wrap('help_tags', l:spec, 0))
endfunction


nnoremap <silent> <leader><leader> :call <SID>PickerFiles()<CR>
nnoremap <silent> <leader>fg :call <SID>PickerLiveGrep()<CR>
nnoremap <silent> <leader>fb :call <SID>PickerBuffers()<CR>
nnoremap <silent> <leader>fh :call <SID>PickerHelp()<CR>

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

" Surround (sa/add, sd/delete, sr/replace) --------------------------
let s:surround_pairs = {
      \ '(': ['(', ')'],
      \ ')': ['(', ')'],
      \ '[': ['[', ']'],
      \ ']': ['[', ']'],
      \ '{': ['{', '}'],
      \ '}': ['{', '}'],
      \ '<': ['<', '>'],
      \ '>': ['<', '>'],
      \ '"': ['"', '"'],
      \ "'": ["'", "'"],
      \ '`': ['`', '`'],
      \ }

function! s:GetPair(ch) abort
  return has_key(s:surround_pairs, a:ch) ? s:surround_pairs[a:ch] : [a:ch, a:ch]
endfunction

function! s:SurroundAdd(type) abort
  let l:ch = input('Surround with: ')
  if empty(l:ch)
    return
  endif
  let [l:left, l:right] = s:GetPair(l:ch[0])
  let [l1, c1] = getpos("'[")[1:2]
  let [l2, c2] = getpos("']")[1:2]
  if l1 == l2
    let l:line = getline(l1)
    call setline(l1, strpart(l:line, 0, c1 - 1) . l:left . strpart(l:line, c1 - 1, c2 - c1 + 1) . l:right . strpart(l:line, c2))
  else
    let l:first = getline(l1)
    let l:last = getline(l2)
    call setline(l1, strpart(l:first, 0, c1 - 1) . l:left . strpart(l:first, c1 - 1))
    call setline(l2, strpart(l:last, 0, c2) . l:right . strpart(l:last, c2))
  endif
endfunction

function! s:SurroundDelete() abort
  let l:ch = input('Delete surrounding: ')
  if empty(l:ch)
    return
  endif
  let [l:left, l:right] = s:GetPair(l:ch[0])
  let l:start = searchpairpos(l:left, '', l:right, 'bnW')
  let l:finish = searchpairpos(l:left, '', l:right, 'nW')
  if l:start[0] == 0 || l:finish[0] == 0
    echo "No surrounding found"
    return
  endif
  if l:start[0] == l:finish[0]
    let l:line = getline(l:start[0])
    let l:line = strpart(l:line, 0, l:finish[1] - 1) . strpart(l:line, l:finish[1])
    let l:line = strpart(l:line, 0, l:start[1] - 1) . strpart(l:line, l:start[1])
    call setline(l:start[0], l:line)
  else
    let l:last = getline(l:finish[0])
    call setline(l:finish[0], strpart(l:last, 0, l:finish[1] - 1) . strpart(l:last, l:finish[1]))
    let l:first = getline(l:start[0])
    call setline(l:start[0], strpart(l:first, 0, l:start[1] - 1) . strpart(l:first, l:start[1]))
  endif
endfunction

function! s:SurroundReplace() abort
  let l:ch = input('Replace surrounding: ')
  if empty(l:ch)
    return
  endif
  let [l:left, l:right] = s:GetPair(l:ch[0])
  let l:start = searchpairpos(l:left, '', l:right, 'bnW')
  let l:finish = searchpairpos(l:left, '', l:right, 'nW')
  if l:start[0] == 0 || l:finish[0] == 0
    echo "No surrounding found"
    return
  endif
  let l:new = input('With: ')
  if empty(l:new)
    return
  endif
  let [l:nl, l:nr] = s:GetPair(l:new[0])
  if l:start[0] == l:finish[0]
    let l:line = getline(l:start[0])
    let l:line = strpart(l:line, 0, l:finish[1] - 1) . l:nr . strpart(l:line, l:finish[1])
    let l:line = strpart(l:line, 0, l:start[1] - 1) . l:nl . strpart(l:line, l:start[1])
    call setline(l:start[0], l:line)
  else
    let l:last = getline(l:finish[0])
    call setline(l:finish[0], strpart(l:last, 0, l:finish[1] - 1) . l:nr . strpart(l:last, l:finish[1]))
    let l:first = getline(l:start[0])
    call setline(l:start[0], strpart(l:first, 0, l:start[1] - 1) . l:nl . strpart(l:first, l:start[1]))
  endif
endfunction

nnoremap <silent> sa :set opfunc=<SID>SurroundAdd<CR>g@
xnoremap <silent> sa :<C-u>call <SID>SurroundAdd('visual')<CR>
nnoremap <silent> sd :call <SID>SurroundDelete()<CR>
nnoremap <silent> sr :call <SID>SurroundReplace()<CR>

" Filetype-specific settings ----------------------------------------
augroup FiletypeSettings
  autocmd!
  autocmd FileType go setlocal shiftwidth=4 tabstop=4 noexpandtab nolist
  autocmd FileType go inoremap <buffer> <C-e> <Cmd>call GoErrSnippet()<CR>
  autocmd FileType c setlocal shiftwidth=4
  autocmd FileType lua setlocal number
  autocmd FileType markdown let b:completion = 0
  autocmd FileType typescript,typescriptreact setlocal shiftwidth=2
augroup END
