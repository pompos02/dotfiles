; extends
(command
  name: (command_name) @command_name
  (#eq? @command_name "awk")
  argument: [
    (string (string_content) @injection.content)
    (raw_string) @injection.content
  ]
  (#set! injection.language "awk"))
