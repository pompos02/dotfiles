return {
    "ej-shafran/compile-mode.nvim",
    version = "^5.0.0",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "compilation",
            callback = function()
                vim.api.nvim_set_option_value("list", false, { scope = "local", win = 0 })
            end,
        })
        vim.g.compile_mode = {
            default_command = "",
            input_word_completion = true,
            use_diagnostics = false,
            error_locus_highlight = 500, -- or true for persistent
            baleia_setup = false,
        }
        local compile_mode = require("compile-mode")
        local errors = require("compile-mode.errors")
        local utils = require("compile-mode.utils")
        local original_parse_errors = compile_mode._parse_errors
        local function value_and_range(line, range)
            return {
                value = line:sub(range.start, range.end_),
                range = range,
            }
        end
        local function number_and_range(line, range)
            local value = tonumber(line:sub(range.start, range.end_))
            if not value then
                return nil
            end
            return {
                value = value,
                range = range,
            }
        end
        local function rust_header(line)
            local code, msg = line:match("^error(%b[]):%s*(.+)$")
            if code then
                return {
                    level = compile_mode.level.ERROR,
                    text = ("error%s: %s"):format(code, msg),
                }
            end
            msg = line:match("^error:%s*(.+)$")
            if msg then
                return {
                    level = compile_mode.level.ERROR,
                    text = "error: " .. msg,
                }
            end
            msg = line:match("^warning:%s*(.+)$")
            if msg then
                return {
                    level = compile_mode.level.WARNING,
                    text = "warning: " .. msg,
                }
            end
            msg = line:match("^note:%s*(.+)$") or line:match("^[ \t]*= note:%s*(.+)$")
            if msg then
                return {
                    level = compile_mode.level.INFO,
                    text = "note: " .. msg,
                }
            end
            msg = line:match("^help:%s*(.+)$") or line:match("^[ \t]*= help:%s*(.+)$")
            if msg then
                return {
                    level = compile_mode.level.INFO,
                    text = "help: " .. msg,
                }
            end
        end
        local function rust_location(line, secondary)
            local pattern
            if secondary then
                pattern = "^[ \t]*::: \\(.\\+\\):\\([0-9]\\+\\):\\([0-9]\\+\\)$"
            else
                pattern = "^[ \t]*--> \\(.\\+\\):\\([0-9]\\+\\):\\([0-9]\\+\\)$"
            end
            local match = utils.matchlistpos(line, pattern)
            if not match[1] or not match[2] or not match[3] or not match[4] then
                return nil
            end
            return {
                full = match[1],
                filename = value_and_range(line, match[2]),
                row = number_and_range(line, match[3]),
                col = number_and_range(line, match[4]),
            }
        end
        local function rehighlight(bufnr, lines)
            local output_highlights = {}
            utils.clear_highlights(bufnr)
            for _, error in pairs(errors.error_list) do
                error.highlighted = false
            end
            for linenum, line in ipairs(lines) do
                if not (linenum == 1 and vim.startswith(line, "vim:")) then
                    local highlights = utils.match_command_ouput(line, linenum)
                    for _, highlight in ipairs(highlights) do
                        table.insert(output_highlights, highlight)
                    end
                end
            end
            errors.highlight(bufnr)
            utils.highlight_command_outputs(bufnr, output_highlights)
            vim.cmd.redrawstatus()
        end
        compile_mode._parse_errors = function(bufnr)
            original_parse_errors(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local current = nil
            local changed = false
            for linenum, line in ipairs(lines) do
                local header = rust_header(line)
                if header then
                    current = header
                else
                    local primary = rust_location(line, false)
                    if primary then
                        errors.error_list[linenum] = {
                            highlighted = false,
                            level = current and current.level or compile_mode.level.ERROR,
                            priority = 100,
                            full = primary.full,
                            full_text = current and current.text or line,
                            filename = primary.filename,
                            row = primary.row,
                            col = primary.col,
                            end_row = nil,
                            end_col = nil,
                            group = "rust",
                            linenum = linenum,
                        }
                        changed = true
                    else
                        local secondary = rust_location(line, true)
                        if secondary and current then
                            errors.error_list[linenum] = {
                                highlighted = false,
                                level = compile_mode.level.INFO,
                                priority = 90,
                                full = secondary.full,
                                full_text = current.text,
                                filename = secondary.filename,
                                row = secondary.row,
                                col = secondary.col,
                                end_row = nil,
                                end_col = nil,
                                group = "rust_secondary",
                                linenum = linenum,
                            }
                            changed = true
                        end
                    end
                end
            end
            if changed then
                rehighlight(bufnr, lines)
            end
        end
        -- Uncomment if you want note/help locations included in :NextError.
        vim.g.compile_mode.error_threshold = compile_mode.level.INFO
    end,
}
