" Vim syntax file
" Language:     Quickfix window

if exists("b:current_syntax")
  finish
endif

syn match qfFileName "^[^|]*" nextgroup=qfSeparator1
syn match qfSeparator1 "|" contained nextgroup=qfLineNr
syn match qfLineNr "[^|]*" contained nextgroup=qfSeparator2 contains=@qfType
syn match qfSeparator2 "|" contained nextgroup=qfText
syn match qfText ".*" contained contains=@qfType

syn match qfError "\<error\>" contained
syn match qfWarning "\<warning\>" contained
syn cluster qfType contains=qfError,qfWarning

if has_key(w:, 'qf_toc') || get(w:, 'quickfix_title') =~# '\<TOC$\|\<Table of contents\>'
  setlocal conceallevel=3 concealcursor=nc
  syn match Ignore "^[^|]*|[^|]*| " conceal
endif

hi def link qfFileName Directory
hi def link qfLineNr LineNr
hi def link qfSeparator1 Delimiter
hi def link qfSeparator2 Delimiter
hi def link qfText Normal

hi def link qfError Error
hi def link qfWarning WarningMsg

let b:current_syntax = "qf"
