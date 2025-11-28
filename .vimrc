"" Leaders first
let mapleader = " "
let maplocalleader = "\\"

colorscheme lunaperche
set background=dark


" Disable fzf history files
let g:fzf_history_dir = ""

" Enable syntax and filetype detection/plugins/indent
syntax enable
filetype plugin indent on

" Options
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
  " Reselect last visual area, yank into register v, and use it for vimgrep
  let l:save_reg = getreg('"')
  let l:save_reg_type = getregtype('"')
  normal! gv"vy
  let l:text = escape(substitute(getreg('v'), '\n\+$', '', ''), '\/')
  call setreg('"', l:save_reg, l:save_reg_type)
  if empty(l:text)
    echo "No selection to grep"
    return
  endif
  call feedkeys(':vimgrep /' . l:text . '/j **/*', 'n')
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
let s:sur_pairs = {
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

function! s:SurGetPair(ch) abort
  return has_key(s:sur_pairs, a:ch) ? s:sur_pairs[a:ch] : [a:ch, a:ch]
endfunction

function! s:SurPromptId(kind) abort
  try
    let l:ch = getcharstr()
  catch /^Vim:Interrupt$/
    return ''
  endtry
  return l:ch ==# "\<Esc>" ? '' : l:ch
endfunction

function! s:SurGetMarks(mode) abort
  if a:mode ==# 'visual'
    let l:a = getpos("'<")
    let l:b = getpos("'>")
    if &selection ==# 'exclusive'
      let l:b[2] -= 1
    endif
  else
    let l:a = getpos("'[")
    let l:b = getpos("']")
  endif
  return [{'line': l:a[1], 'col': l:a[2]}, {'line': l:b[1], 'col': l:b[2]}]
endfunction

function! s:SurInsert(line, col, text) abort
  let l:ln = getline(a:line)
  let l:idx = max([0, a:col - 1])
  call setline(a:line, strpart(l:ln, 0, l:idx) . a:text . strpart(l:ln, l:idx))
endfunction

function! s:SurAdd(mode) abort
  let l:id = s:SurPromptId('output')
  if empty(l:id) | return | endif
  let [l:left, l:right] = s:SurGetPair(l:id[0])
  let [l:pos1, l:pos2] = s:SurGetMarks(a:mode)
  " insert right after end (inclusive), left before start
  call s:SurInsert(l:pos2.line, l:pos2.col + 1, l:right)
  call s:SurInsert(l:pos1.line, l:pos1.col, l:left)
  call cursor(l:pos1.line, l:pos1.col + strlen(l:left))
endfunction

function! s:SurFindAround(ch) abort
  let [l:left, l:right] = s:SurGetPair(a:ch)
  let l:save = getpos('.')
  let l:s = []
  if l:left ==# l:right
    let l:pat = '\V' . escape(l:left, '\')
    let l:beg = searchpos(l:pat, 'bnW')
    call setpos('.', l:save)
    let l:end = searchpos(l:pat, 'nW')
    call setpos('.', l:save)
  else
    let l:beg = searchpairpos('\V'.escape(l:left,'\'), '', '\V'.escape(l:right,'\'), 'bnW')
    call setpos('.', l:save)
    let l:end = searchpairpos('\V'.escape(l:left,'\'), '', '\V'.escape(l:right,'\'), 'nW')
    call setpos('.', l:save)
  endif
  if empty(l:beg) || empty(l:end) || l:beg[0] == 0 || l:end[0] == 0
    return {}
  endif
  return {'left': {'line': l:beg[0], 'col': l:beg[1]}, 'right': {'line': l:end[0], 'col': l:end[1]}}
endfunction

function! s:SurDelete() abort
  let l:id = s:SurPromptId('input')
  if empty(l:id) | return | endif
  let l:surr = s:SurFindAround(l:id[0])
  if empty(l:surr)
    echo "No surrounding found"
    return
  endif
  let l:ln = getline(l:surr.right.line)
  call setline(l:surr.right.line, strpart(l:ln, 0, l:surr.right.col - 1) . strpart(l:ln, l:surr.right.col))
  let l:ln = getline(l:surr.left.line)
  call setline(l:surr.left.line, strpart(l:ln, 0, l:surr.left.col - 1) . strpart(l:ln, l:surr.left.col))
  call cursor(l:surr.left.line, l:surr.left.col)
endfunction

function! s:SurReplace() abort
  let l:id = s:SurPromptId('input')
  if empty(l:id) | return | endif
  let l:surr = s:SurFindAround(l:id[0])
  if empty(l:surr)
    echo "No surrounding found"
    return
  endif
  let l:new = s:SurPromptId('output')
  if empty(l:new) | return | endif
  let [l:nl, l:nr] = s:SurGetPair(l:new[0])
  let l:ln = getline(l:surr.right.line)
  call setline(l:surr.right.line, strpart(l:ln, 0, l:surr.right.col - 1) . l:nr . strpart(l:ln, l:surr.right.col))
  let l:ln = getline(l:surr.left.line)
  call setline(l:surr.left.line, strpart(l:ln, 0, l:surr.left.col - 1) . l:nl . strpart(l:ln, l:surr.left.col))
  call cursor(l:surr.left.line, l:surr.left.col + strlen(l:nl))
endfunction

nnoremap <silent> sa :set opfunc=<SID>SurAdd<CR>g@
xnoremap <silent> sa :<C-u>call <SID>SurAdd('visual')<CR>
nnoremap <silent> sd :call <SID>SurDelete()<CR>
nnoremap <silent> sr :call <SID>SurReplace()<CR>

" Filetype-specific settings ----------------------------------------
augroup FiletypeSettings
  autocmd!
  autocmd FileType go setlocal shiftwidth=4 tabstop=4 noexpandtab nolist
  autocmd FileType c setlocal shiftwidth=4
  autocmd FileType lua setlocal number
  autocmd FileType markdown let b:completion = 0
  autocmd FileType typescript,typescriptreact setlocal shiftwidth=2
augroup END
