---@module 'luassert'

local util = require('tests.util')

describe('completions', function()
    local lines = {
        '# Heading',
        '',
        '-',
        '',
        '- ',
        '',
        '- [',
        '',
        '- [-',
        '',
        '- [-]',
        '',
        '- [-] ',
        '',
        '- [-] todo',
        '',
        '- text',
        '',
        '# Heading',
        '',
        '>',
        '',
        '> ',
        '',
        '> [',
        '',
        '> [!',
        '',
        '> [!TIP',
        '',
        '> [!TIP]',
        '',
        '> [!TIP] My Tip',
        '',
        '> text',
    }

    ---@param row render.md.test.Row
    ---@param n integer
    ---@param col integer
    ---@param expected lsp.CompletionItem[]
    local function validate(row, n, col, expected)
        local source = require('render-markdown.integ.source')
        local actual = source.items(0, row:get(n)[1], col) or {}
        table.sort(actual, function(a, b)
            return a.label < b.label
        end)
        assert.same(expected, actual)
    end

    ---@param prefix string
    ---@param suffix string
    ---@param label string
    ---@param detail string
    ---@param description? string
    ---@return lsp.CompletionItem
    local function item(prefix, suffix, label, detail, description)
        ---@type lsp.CompletionItem
        return {
            kind = 12,
            label = label,
            labelDetails = {
                detail = ' ' .. detail,
                description = description,
            },
            insertText = prefix .. label .. suffix,
        }
    end

    it('checkbox', function()
        util.setup.text(lines)

        ---@param prefix string
        ---@return lsp.CompletionItem[]
        local function items(prefix)
            return {
                item(prefix, ' ', '[ ]', '[ ] ', 'unchecked'),
                item(prefix, ' ', '[-]', '[-] ', 'todo'),
                item(prefix, ' ', '[x]', '[x] ', 'checked'),
            }
        end

        local row = util.row()
        validate(row, 2, 1, items(' '))
        validate(row, 2, 2, items(''))
        validate(row, 2, 3, items(''))
        validate(row, 2, 4, items(''))
        validate(row, 2, 5, {})
        validate(row, 2, 6, {})
        validate(row, 2, 10, {})
        validate(row, 2, 6, {})
        validate(row, 1, 0, {})
    end)

    it('callout', function()
        util.setup.text(lines)

        ---@param prefix string
        ---@return lsp.CompletionItem[]
        local function items(prefix)
            return {
                item(prefix, '', '[!ABSTRACT]', '[sum] Abstract'),
                item(prefix, '', '[!ATTENTION]', '[warn] Attention'),
                item(prefix, '', '[!BUG]', '[bug] Bug'),
                item(prefix, '', '[!CAUTION]', '[caution] Caution'),
                item(prefix, '', '[!CHECK]', '[ok] Check'),
                item(prefix, '', '[!CITE]', '[quote] Cite'),
                item(prefix, '', '[!DANGER]', '[!!] Danger'),
                item(prefix, '', '[!DONE]', '[ok] Done'),
                item(prefix, '', '[!ERROR]', '[!!] Error'),
                item(prefix, '', '[!EXAMPLE]', '[ex] Example'),
                item(prefix, '', '[!FAILURE]', '[x] Failure'),
                item(prefix, '', '[!FAIL]', '[x] Fail'),
                item(prefix, '', '[!FAQ]', '[?] Faq'),
                item(prefix, '', '[!HELP]', '[?] Help'),
                item(prefix, '', '[!HINT]', '[tip] Hint'),
                item(prefix, '', '[!IMPORTANT]', '[!] Important'),
                item(prefix, '', '[!INFO]', '[i] Info'),
                item(prefix, '', '[!MISSING]', '[x] Missing'),
                item(prefix, '', '[!NOTE]', '[i] Note'),
                item(prefix, '', '[!QUESTION]', '[?] Question'),
                item(prefix, '', '[!QUOTE]', '[quote] Quote'),
                item(prefix, '', '[!SUCCESS]', '[ok] Success'),
                item(prefix, '', '[!SUMMARY]', '[sum] Summary'),
                item(prefix, '', '[!TIP]', '[tip] Tip'),
                item(prefix, '', '[!TLDR]', '[sum] Tldr'),
                item(prefix, '', '[!TODO]', '[todo] Todo'),
                item(prefix, '', '[!WARNING]', '[warn] Warning'),
            }
        end

        local row = util.row()
        validate(row, 20, 1, items(' '))
        validate(row, 2, 2, items(''))
        validate(row, 2, 3, items(''))
        validate(row, 2, 4, items(''))
        validate(row, 2, 7, items(''))
        validate(row, 2, 8, {})
        validate(row, 2, 15, {})
        validate(row, 2, 6, {})
    end)
end)
