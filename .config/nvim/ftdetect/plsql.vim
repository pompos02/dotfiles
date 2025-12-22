augroup filetypedetect
  au! BufRead,BufNewFile *.sql,*.pls,*.pks,*.pkb,*.plsql setfiletype plsql
augroup END
