---@module 'luassert'

local util = require('tests.util')

describe('demo/callout.md', function()
    it('default', function()
        util.setup.file('demo/callout.md')

        local marks, row = util.marks(), util.row()

        marks:add(row:get(0), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        local info = 'RmInfo'
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(info))
        marks:add(row:get(0, 0), { 2, 9 }, {
            virt_text = { { '[i] Note', info } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(info))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(info))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(info))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(info))

        marks:add(row:get(2), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        local ok = 'RmSuccess'
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(ok))
        marks:add(row:get(0, 0), { 2, 8 }, {
            virt_text = { { '[tip] Tip', ok } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(ok))
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(ok))
        marks:add(row:get(0), 2, util.code.sign('lua'))
        marks:add(row:get(0), 2, util.code.border('=', true, 'lua', 16))
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal())
        marks:add(row:get(0, 0), { 5, 8 }, util.conceal())
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(ok))
        marks:add(row:get(0, 1), { 2, 0 }, util.code.bg())
        marks:add(row:get(0, 0), { 0, 1 }, util.quote(ok))
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal())
        marks:add(row:get(0, 0), { 2, 5 }, util.conceal_lines())

        marks:add(row:get(2), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        local hint = 'RmHint'
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(hint))
        marks:add(row:get(0, 0), { 2, 14 }, {
            virt_text = { { '[!] Important', hint } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(hint))

        marks:add(row:get(2), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        local warn = 'RmWarn'
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(warn))
        marks:add(row:get(0, 0), { 2, 12 }, {
            virt_text = { { '[warn] Custom Title', warn } },
            virt_text_pos = 'overlay',
            conceal = '',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(warn))

        marks:add(row:get(2), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        local err = 'RmError'
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(err))
        marks:add(row:get(0, 0), { 2, 12 }, {
            virt_text = { { '[caution] Caution', err } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(err))

        marks:add(row:get(2), 0, util.heading.sign(1))
        marks:add(row:get(0, 0), { 0, 1 }, util.heading.icon(1))
        marks:add(row:get(0, 1), { 0, 0 }, util.heading.bg(1))

        marks:add(row:get(1, 0), { 0, 1 }, util.quote(err))
        marks:add(row:get(0, 0), { 2, 8 }, {
            virt_text = { { '[bug] Bug', err } },
            virt_text_pos = 'overlay',
        })
        marks:add(row:get(1, 0), { 0, 1 }, util.quote(err))

        util.assert_view(marks, {
            '> H1 Note',
            '',
            '  > [i] Note',
            '  >',
            '  > A regular note',
            '  >',
            '  > With a second paragraph',
            '',
            '> H1 Tip',
            '',
            '  > [tip] Tip',
            '  >',
            '󰢱 > 󰢱 lua=======================================================================',
            "  > print('Standard tip')",
            '',
            '> H1 Important',
            '',
            '  > [!] Important',
            '  > Exceptional info',
            '',
            '> H1 Warning',
            '',
            '  > [warn] Custom Title',
            '  > Dastardly surprise',
            '',
            '> H1 Caution',
            '',
            '  > [caution] Caution',
            '  > Cautionary tale',
            '',
            '> H1 Bug',
            '',
            '  > [bug] Bug',
            '  > Custom bug',
        })
    end)
end)
