; Inject text language for word-level Git keyword highlighting
; Text parser should tokenize individual words
((message_line) @injection.content
 (#set! injection.language "markdown"))

((diff) @injection.content
 (#set! injection.language "diff"))

((rebase_command) @injection.content
 (#set! injection.language "git_rebase"))

