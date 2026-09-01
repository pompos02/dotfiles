local api, fn = vim.api, vim.fn
local ts_highlighter = vim.treesitter.highlighter

local M = {}

local state_by_buf = {}
local window_contexts = {}
local ts_ns = api.nvim_create_namespace("plsql_context_ts")

local defaults = {
    max_lines = 10,
    mode = "cursor",
    zindex = 20,
}

local PARSE_CACHE_MAX_ENTRIES = 192

local function darken_color(color, ratio)
    local r = math.floor(color / 0x10000) % 0x100
    local g = math.floor(color / 0x100) % 0x100
    local b = color % 0x100

    local function darken(c)
        return math.max(0, math.floor(c * ratio))
    end

    return string.format("#%02x%02x%02x", darken(r), darken(g), darken(b))
end

local function setup_highlights()
    if fn.hlexists("TreesitterContext") == 1 then
        api.nvim_set_hl(0, "PlsqlContext", { default = true, link = "TreesitterContext" })
        return
    end

    local ok_normal, normal = pcall(api.nvim_get_hl, 0, { name = "Normal", link = false })
    local ok_float, normal_float = pcall(api.nvim_get_hl, 0, { name = "NormalFloat", link = false })

    if ok_float and ok_normal and normal_float.bg and normal.bg and normal_float.bg ~= normal.bg then
        api.nvim_set_hl(0, "PlsqlContext", { default = true, link = "NormalFloat" })
        return
    end

    if ok_normal and normal.bg then
        api.nvim_set_hl(0, "PlsqlContext", { default = true, bg = darken_color(normal.bg, 0.9) })
        return
    end

    api.nvim_set_hl(0, "PlsqlContext", { default = true, link = "NormalFloat" })
end

local OBJECT_NAME_PATTERN = '[%w_$#%."]+'

local q_quote_pairs = {
    ["["] = "]",
    ["("] = ")",
    ["{"] = "}",
    ["<"] = ">",
}

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function compact(s)
    return trim(s:gsub("%s+", " "))
end

local function has_keyword(s, keyword)
    return s:match("%f[%a]" .. keyword .. "%f[%A]") ~= nil
end

local function sanitize_line(line, parser_state)
    if not parser_state.block_comment
        and not line:find("'", 1, true)
        and not line:find("-", 1, true)
        and not line:find("/", 1, true)
    then
        return line
    end

    local out = {}
    local i = 1

    while i <= #line do
        local two = line:sub(i, i + 1)
        local c = line:sub(i, i)

        if parser_state.block_comment then
            if two == "*/" then
                parser_state.block_comment = false
                out[#out + 1] = " "
                i = i + 2
            else
                i = i + 1
            end
        elseif two == "/*" then
            parser_state.block_comment = true
            out[#out + 1] = " "
            i = i + 2
        elseif two == "--" then
            break
        elseif (c == "q" or c == "Q") and line:sub(i + 1, i + 1) == "'" then
            local opener = line:sub(i + 2, i + 2)
            local closer = q_quote_pairs[opener] or opener
            if opener == "" then
                out[#out + 1] = c
                i = i + 1
            else
                out[#out + 1] = " "
                i = i + 3
                while i <= #line do
                    if line:sub(i, i) == closer and line:sub(i + 1, i + 1) == "'" then
                        i = i + 2
                        break
                    end
                    i = i + 1
                end
            end
        elseif c == "'" then
            out[#out + 1] = " "
            i = i + 1
            while i <= #line do
                if line:sub(i, i) == "'" then
                    if line:sub(i + 1, i + 1) == "'" then
                        i = i + 2
                    else
                        i = i + 1
                        break
                    end
                else
                    i = i + 1
                end
            end
        else
            out[#out + 1] = c
            i = i + 1
        end
    end

    return table.concat(out)
end

local function push_block(stack, kind, lnum, text, close_kind, awaiting_begin, end_lnum)
    stack[#stack + 1] = {
        kind = kind,
        lnum = lnum,
        text = text,
        start_lnum = lnum,
        end_lnum = end_lnum or lnum,
        close_kind = close_kind or "plain",
        awaiting_begin = awaiting_begin == true,
    }
end

local function pop_until(stack, close_kind)
    for i = #stack, 1, -1 do
        if stack[i].close_kind == close_kind then
            for _ = #stack, i, -1 do
                table.remove(stack)
            end
            return
        end
    end

    if #stack > 0 then
        table.remove(stack)
    end
end

local function pop_plain_end(stack)
    pop_until(stack, "plain")
end

local function consume_begin_or_open(stack, lnum, text)
    local top = stack[#stack]
    if top and top.awaiting_begin then
        top.awaiting_begin = false
        return
    end

    push_block(stack, "begin", lnum, text, "plain", false)
end

local function starts_plain_end(lower)
    return lower:match("^end%s*;") or lower:match("^end%s+" .. OBJECT_NAME_PATTERN .. "%s*;")
end

local function is_subprogram_start(lower)
    return lower:match("^create%s+or%s+replace%s+procedure%s+" .. OBJECT_NAME_PATTERN)
        or lower:match("^create%s+or%s+replace%s+function%s+" .. OBJECT_NAME_PATTERN)
        or lower:match("^procedure%s+" .. OBJECT_NAME_PATTERN)
        or lower:match("^function%s+" .. OBJECT_NAME_PATTERN)
end

local function clone_stack(stack)
    local copy = {}
    for i = 1, #stack do
        local item = stack[i]
        copy[i] = {
            kind = item.kind,
            lnum = item.lnum,
            text = item.text,
            start_lnum = item.start_lnum,
            end_lnum = item.end_lnum,
            close_kind = item.close_kind,
            awaiting_begin = item.awaiting_begin == true,
        }
    end

    return copy
end

local function clone_pending(pending)
    if not pending then
        return nil
    end

    return {
        kind = pending.kind,
        lnum = pending.lnum,
        text = pending.text,
        awaiting_begin = pending.awaiting_begin == true,
        end_lnum = pending.end_lnum,
    }
end

local function parse_line(raw, lnum, parse_state)
    local stack = parse_state.stack
    local parser_state = parse_state.parser_state
    local pending = parse_state.pending
    local sanitized = sanitize_line(raw, parser_state)
    local line = compact(sanitized)
    local lower = line:lower()

    if lower == "" then
        parse_state.pending = pending
        return
    end

    if lower:match("^end%s+if%s*;") then
        pending = nil
        pop_until(stack, "if")
    elseif lower:match("^end%s+loop%s*;") then
        pending = nil
        pop_until(stack, "loop")
    elseif lower:match("^end%s+case%s*;") then
        pending = nil
        pop_until(stack, "case")
    elseif starts_plain_end(lower) then
        pending = nil
        pop_plain_end(stack)
    else
        if pending then
            pending.end_lnum = lnum
            if has_keyword(lower, "is") or has_keyword(lower, "as") then
                push_block(
                    stack,
                    pending.kind,
                    pending.lnum,
                    pending.text,
                    "plain",
                    pending.awaiting_begin,
                    pending.end_lnum
                )
                pending = nil
            elseif lower:match(";%s*$") then
                pending = nil
            end
        end

        local opened_decl = false

        if lower:match("^create%s+or%s+replace%s+package%s+body%s+" .. OBJECT_NAME_PATTERN) then
            push_block(stack, "package", lnum, raw, "plain", true)
            opened_decl = true
        elseif lower:match("^create%s+or%s+replace%s+package%s+" .. OBJECT_NAME_PATTERN) then
            push_block(stack, "package", lnum, raw, "plain", false)
            opened_decl = true
        elseif lower:match("^create%s+or%s+replace%s+trigger%s+" .. OBJECT_NAME_PATTERN) then
            push_block(stack, "trigger", lnum, raw, "plain", true)
            opened_decl = true
        elseif is_subprogram_start(lower) then
            local has_body = has_keyword(lower, "is") or has_keyword(lower, "as")
            if has_body then
                push_block(stack, "subprogram", lnum, raw, "plain", true, lnum)
            elseif not lower:match(";%s*$") then
                pending = {
                    kind = "subprogram",
                    lnum = lnum,
                    text = raw,
                    awaiting_begin = true,
                    end_lnum = lnum,
                }
            end
            opened_decl = true
        end

        if lower:match("^declare%f[%W]") then
            push_block(stack, "declare", lnum, raw, "plain", true)
        end

        if lower:match("^begin%f[%W]") then
            consume_begin_or_open(stack, lnum, raw)
        end

        if not opened_decl then
            if lower:match("^if%f[%W].-%f[%a]then%f[%A]") then
                push_block(stack, "if", lnum, raw, "if", false)
            elseif lower:match("^for%f[%W].-%f[%a]loop%f[%A]")
                or lower:match("^while%f[%W].-%f[%a]loop%f[%A]")
                or lower:match("^loop%f[%W]")
            then
                push_block(stack, "loop", lnum, raw, "loop", false)
            elseif lower:match("^case%f[%W]") then
                push_block(stack, "case", lnum, raw, "case", false)
            end
        end
    end

    parse_state.pending = pending
end

local function ensure_parse_cache(state, bufnr)
    local tick = api.nvim_buf_get_changedtick(bufnr)
    local cache = state.parse_cache

    if cache and cache.tick == tick then
        return cache
    end

    cache = {
        tick = tick,
        entries = {
            [0] = {
                stack = {},
                parser_state = { block_comment = false },
                pending = nil,
            },
        },
        order = { 0 },
    }
    state.parse_cache = cache

    return cache
end

local function parse_open_blocks(bufnr, stop_lnum, state)
    local stop = math.max(0, stop_lnum or 0)
    if stop == 0 then
        return {}
    end

    if not state then
        local runtime = {
            stack = {},
            parser_state = { block_comment = false },
            pending = nil,
        }
        local lines = api.nvim_buf_get_lines(bufnr, 0, stop, false)
        for lnum, raw in ipairs(lines) do
            parse_line(raw, lnum, runtime)
        end
        return runtime.stack
    end

    local cache = ensure_parse_cache(state, bufnr)
    local existing = cache.entries[stop]
    if existing then
        return existing.stack
    end

    local best_lnum = 0
    local best_entry = cache.entries[0]
    for cached_lnum, entry in pairs(cache.entries) do
        if cached_lnum <= stop and cached_lnum >= best_lnum then
            best_lnum = cached_lnum
            best_entry = entry
        end
    end

    local runtime = {
        stack = clone_stack(best_entry.stack),
        parser_state = {
            block_comment = best_entry.parser_state.block_comment == true,
        },
        pending = clone_pending(best_entry.pending),
    }

    if best_lnum < stop then
        local lines = api.nvim_buf_get_lines(bufnr, best_lnum, stop, false)
        for idx, raw in ipairs(lines) do
            parse_line(raw, best_lnum + idx, runtime)
        end
    end

    cache.entries[stop] = runtime
    cache.order[#cache.order + 1] = stop

    if #cache.order > PARSE_CACHE_MAX_ENTRIES then
        local evict = table.remove(cache.order, 2)
        if evict then
            cache.entries[evict] = nil
        end
    end

    return runtime.stack
end

local function normalize_opts(opts)
    local merged = vim.tbl_extend("force", defaults, opts or {})

    local max_lines = tonumber(merged.max_lines) or defaults.max_lines
    if max_lines < 1 then
        max_lines = defaults.max_lines
    end

    local zindex = tonumber(merged.zindex) or defaults.zindex
    if zindex < 1 then
        zindex = defaults.zindex
    end

    merged.max_lines = max_lines
    merged.mode = merged.mode == "topline" and "topline" or "cursor"
    merged.zindex = zindex

    return merged
end

local function set_lines(bufnr, lines)
    local current = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local changed = #current ~= #lines

    if not changed then
        for i, line in ipairs(current) do
            if line ~= lines[i] then
                changed = true
                break
            end
        end
    end

    if changed then
        vim.bo[bufnr].modifiable = true
        api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.bo[bufnr].modifiable = false
        vim.bo[bufnr].modified = false
    end

    return changed
end

local function copy_buf_option(name, from_buf, to_buf)
    local value = vim.bo[from_buf][name]
    if vim.bo[to_buf][name] ~= value then
        vim.bo[to_buf][name] = value
    end
end

local function get_hl_from_capture(buf_query, capture)
    if buf_query.get_hl_from_capture then
        return buf_query:get_hl_from_capture(capture)
    end

    if buf_query.hl_cache then
        return buf_query.hl_cache[capture]
    end
end

local TS_PRIORITY = ((vim.hl and vim.hl.priorities and vim.hl.priorities.treesitter)
    or (vim.highlight and vim.highlight.priorities and vim.highlight.priorities.treesitter)
    or 100)

local function highlight_context_treesitter(src_buf, dst_buf, source_lnums, rendered_lines)
    if #source_lnums == 0 then
        return
    end

    local buf_highlighter = ts_highlighter and ts_highlighter.active and ts_highlighter.active[src_buf]
    if not buf_highlighter or not buf_highlighter.tree then
        copy_buf_option("syntax", src_buf, dst_buf)
        return
    end

    local row_map = {}
    local min_row = source_lnums[1] - 1
    local max_row = min_row

    for dst_idx, lnum in ipairs(source_lnums) do
        local src_row = lnum - 1
        row_map[src_row] = row_map[src_row] or {}
        row_map[src_row][#row_map[src_row] + 1] = {
            dst_row = dst_idx - 1,
            line_len = #(rendered_lines[dst_idx] or ""),
        }

        if src_row < min_row then
            min_row = src_row
        end
        if src_row > max_row then
            max_row = src_row
        end
    end

    buf_highlighter.tree:for_each_tree(function(tstree, ltree)
        local ok_query, buf_query = pcall(buf_highlighter.get_query, buf_highlighter, ltree:lang())
        if not ok_query or not buf_query then
            return
        end

        local query = buf_query.query and buf_query:query() or nil
        if not query then
            return
        end

        for capture, node, metadata in query:iter_captures(tstree:root(), src_buf, min_row, max_row + 1) do
            metadata = metadata or {}
            local range = vim.treesitter.get_range(node, src_buf, metadata[capture])
            local nsrow, nscol, nerow, necol = range[1], range[2], range[4], range[5]

            if nsrow <= max_row and nerow >= min_row then
                local hl_group = get_hl_from_capture(buf_query, capture)
                if hl_group then
                    local priority = tonumber(metadata.priority) or TS_PRIORITY
                    local conceal = metadata.conceal or (metadata[capture] and metadata[capture].conceal)
                    local from_row = math.max(nsrow, min_row)
                    local to_row = math.min(nerow, max_row)

                    for src_row = from_row, to_row do
                        local mapped_rows = row_map[src_row]
                        if mapped_rows then
                            local start_col = src_row == nsrow and nscol or 0

                            for _, mapped in ipairs(mapped_rows) do
                                local end_col = src_row == nerow and necol or mapped.line_len

                                if end_col > start_col then
                                    pcall(api.nvim_buf_set_extmark, dst_buf, ts_ns, mapped.dst_row, start_col, {
                                        end_row = mapped.dst_row,
                                        end_col = end_col,
                                        priority = priority,
                                        hl_group = hl_group,
                                        conceal = conceal,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local ns_kind_cache = nil

local function is_core_namespace(ns_id)
    if ns_kind_cache and ns_kind_cache[ns_id] ~= nil then
        return ns_kind_cache[ns_id]
    end

    ns_kind_cache = {}
    for name, id in pairs(api.nvim_get_namespaces()) do
        ns_kind_cache[id] = vim.startswith(name, "nvim.")
    end

    return ns_kind_cache[ns_id] == true
end

local function copy_core_extmarks(src_buf, dst_buf, source_lnums)
    if #source_lnums == 0 then
        return
    end

    local row_to_dst = {}
    local min_row = source_lnums[1] - 1
    local max_row = min_row

    for dst_row1, lnum in ipairs(source_lnums) do
        local src_row = lnum - 1
        row_to_dst[src_row] = row_to_dst[src_row] or {}
        row_to_dst[src_row][#row_to_dst[src_row] + 1] = dst_row1 - 1

        if src_row < min_row then
            min_row = src_row
        end
        if src_row > max_row then
            max_row = src_row
        end
    end

    local marks = api.nvim_buf_get_extmarks(src_buf, -1, { min_row, 0 }, { max_row + 1, 0 }, { details = true })
    for _, mark in ipairs(marks) do
        local row = mark[2]
        local col = mark[3]
        local opts = mark[4]
        local dst_rows = row_to_dst[row]

        if dst_rows and is_core_namespace(opts.ns_id) and (opts.hl_group or opts.line_hl_group) then
            local clipped_end_row
            local clipped_end_col
            if opts.end_row then
                clipped_end_row = opts.end_row
                clipped_end_col = opts.end_col or 0

                if clipped_end_row > row + 1 or (clipped_end_row == row + 1 and clipped_end_col > 0) then
                    clipped_end_row = row + 1
                    clipped_end_col = 0
                end
            end

            for _, dst_row in ipairs(dst_rows) do
                local extmark_opts = {
                    priority = opts.priority,
                    hl_group = opts.hl_group,
                    line_hl_group = opts.line_hl_group,
                    hl_eol = opts.hl_eol,
                    conceal = opts.conceal,
                    spell = opts.spell,
                    right_gravity = opts.right_gravity,
                    end_right_gravity = opts.end_right_gravity,
                }

                if clipped_end_row then
                    extmark_opts.end_row = dst_row + (clipped_end_row - row)
                    extmark_opts.end_col = clipped_end_col
                end

                pcall(api.nvim_buf_set_extmark, dst_buf, opts.ns_id, dst_row, col, extmark_opts)
            end
        end
    end
end

local function sync_horizontal_scroll(winid, ctx)
    if not ctx or not ctx.context_winid or not api.nvim_win_is_valid(ctx.context_winid) then
        return
    end

    local leftcol = api.nvim_win_call(winid, function()
        return fn.winsaveview().leftcol
    end)

    if ctx.last_leftcol ~= leftcol then
        ctx.last_leftcol = leftcol
        api.nvim_win_call(ctx.context_winid, function()
            fn.winrestview({ leftcol = leftcol })
        end)
    end
end

local function close_context_window(winid)
    local ctx = window_contexts[winid]
    if not ctx then
        return
    end

    if ctx.context_winid and api.nvim_win_is_valid(ctx.context_winid) then
        pcall(api.nvim_win_close, ctx.context_winid, true)
    end

    if ctx.context_bufnr and api.nvim_buf_is_valid(ctx.context_bufnr) then
        pcall(api.nvim_buf_delete, ctx.context_bufnr, { force = true })
    end

    window_contexts[winid] = nil
end

local function close_contexts_for_buf(bufnr)
    for winid, ctx in pairs(window_contexts) do
        if ctx.bufnr == bufnr then
            close_context_window(winid)
        end
    end
end

local function cleanup_orphaned_contexts()
    for winid, ctx in pairs(window_contexts) do
        if not api.nvim_win_is_valid(winid) then
            close_context_window(winid)
        elseif not state_by_buf[ctx.bufnr] then
            close_context_window(winid)
        elseif api.nvim_win_get_buf(winid) ~= ctx.bufnr then
            close_context_window(winid)
        end
    end
end

local function collect_context(bufnr, opts, state, cursor, topline, cutoff)
    if cutoff < 1 then
        return nil
    end

    local stack = parse_open_blocks(bufnr, cutoff, state)
    local hidden = {}

    for _, item in ipairs(stack) do
        local start_lnum = item.start_lnum or item.lnum
        local end_lnum = item.end_lnum or item.lnum
        local clipped_end = math.min(end_lnum, topline - 1)

        if start_lnum <= clipped_end then
            hidden[#hidden + 1] = {
                start_lnum = start_lnum,
                end_lnum = clipped_end,
            }
        end
    end

    if #hidden == 0 then
        return nil
    end

    local max_from_cursor = math.max(0, cursor - topline)
    local max_lines = math.min(opts.max_lines, max_from_cursor)
    if max_lines <= 0 then
        return nil
    end

    local total_lines = 0
    for _, range in ipairs(hidden) do
        total_lines = total_lines + (range.end_lnum - range.start_lnum + 1)
    end

    while total_lines > max_lines and #hidden > 0 do
        local first = hidden[1]
        local height = first.end_lnum - first.start_lnum + 1
        local overflow = total_lines - max_lines

        if height <= overflow then
            table.remove(hidden, 1)
            total_lines = total_lines - height
        else
            first.start_lnum = first.start_lnum + overflow
            total_lines = total_lines - overflow
        end
    end

    if #hidden == 0 then
        return nil
    end

    local line_numbers = {}
    local lines = {}

    for _, range in ipairs(hidden) do
        local src_lines = api.nvim_buf_get_lines(bufnr, range.start_lnum - 1, range.end_lnum, false)
        for idx, text in ipairs(src_lines) do
            line_numbers[#line_numbers + 1] = range.start_lnum + idx - 1
            lines[#lines + 1] = text
        end
    end

    if #lines == 0 then
        return nil
    end

    return {
        lines = lines,
        line_numbers = line_numbers,
        topline = topline,
    }
end

local function make_context_key(line_numbers, lines, ts_ready)
    local parts = { ts_ready and "1" or "0", "#" }

    for i = 1, #line_numbers do
        local line = lines[i] or ""
        parts[#parts + 1] = tostring(line_numbers[i])
        parts[#parts + 1] = ":"
        parts[#parts + 1] = tostring(#line)
        parts[#parts + 1] = ":"
        parts[#parts + 1] = line
        parts[#parts + 1] = "|"
    end

    return table.concat(parts)
end

local function is_target_window(winid, bufnr)
    return api.nvim_win_is_valid(winid)
        and api.nvim_win_get_buf(winid) == bufnr
        and not vim.wo[winid].previewwindow
        and api.nvim_win_get_height(winid) >= 2
end

local function get_textoff(winid)
    local info = fn.getwininfo(winid)
    return (info[1] and info[1].textoff) or 0
end

local function ensure_context_window(winid, bufnr, opts, height, textoff, width, conceallevel)
    local ctx = window_contexts[winid]
    if ctx and ctx.bufnr ~= bufnr then
        close_context_window(winid)
        ctx = nil
    end

    if not ctx then
        local context_buf = api.nvim_create_buf(false, true)
        vim.bo[context_buf].buftype = "nofile"
        vim.bo[context_buf].bufhidden = "wipe"
        vim.bo[context_buf].buflisted = false
        vim.bo[context_buf].swapfile = false
        vim.bo[context_buf].modifiable = false
        vim.bo[context_buf].undolevels = -1

        ctx = {
            bufnr = bufnr,
            context_bufnr = context_buf,
            context_winid = nil,
        }
        window_contexts[winid] = ctx
    end

    textoff = textoff or get_textoff(winid)
    width = width or math.max(1, api.nvim_win_get_width(winid) - textoff)
    local win_config = {
        win = winid,
        relative = "win",
        width = width,
        height = height,
        row = 0,
        col = textoff,
        focusable = false,
        style = "minimal",
        border = "none",
        zindex = opts.zindex,
    }

    if not ctx.context_winid or not api.nvim_win_is_valid(ctx.context_winid) then
        local open_config = vim.tbl_extend("force", win_config, { noautocmd = true })
        ctx.context_winid = api.nvim_open_win(ctx.context_bufnr, false, open_config)
        ctx.last_leftcol = nil
        vim.w[ctx.context_winid].plsql_context_window = true
        vim.wo[ctx.context_winid].wrap = false
        vim.wo[ctx.context_winid].foldenable = false
        vim.wo[ctx.context_winid].number = false
        vim.wo[ctx.context_winid].relativenumber = false
        vim.wo[ctx.context_winid].signcolumn = "no"
        vim.wo[ctx.context_winid].cursorline = false
        vim.wo[ctx.context_winid].winhl = "NormalFloat:PlsqlContext"
    else
        api.nvim_win_set_config(ctx.context_winid, win_config)
    end

    if api.nvim_win_is_valid(ctx.context_winid) then
        vim.wo[ctx.context_winid].conceallevel = conceallevel or vim.wo[winid].conceallevel
    end

    return ctx
end

local function render_window(bufnr, win_info, state)
    local winid = win_info.winid
    local opts = state.opts
    if not is_target_window(winid, bufnr) then
        close_context_window(winid)
        return
    end

    local cursor = win_info.cursor
    local topline = win_info.topline
    local cutoff = win_info.cutoff
    local win_width = win_info.win_width
    local textoff = win_info.textoff
    local context_width = math.max(1, win_width - textoff)
    local conceallevel = win_info.conceallevel
    local changedtick = api.nvim_buf_get_changedtick(bufnr)
    local ts_ready = ts_highlighter
        and ts_highlighter.active
        and ts_highlighter.active[bufnr]
        and ts_highlighter.active[bufnr].tree
    local existing_ctx = window_contexts[winid]
    local ts_flag = ts_ready and 1 or 0
    local logic_key = table.concat({
        changedtick,
        cursor,
        topline,
        cutoff,
        ts_flag,
        opts.max_lines,
        opts.mode,
    }, ":")
    local view_key = table.concat({
        logic_key,
        win_width,
        textoff,
        conceallevel,
        opts.zindex,
    }, ":")

    if existing_ctx and existing_ctx.bufnr == bufnr and existing_ctx.last_view_key == view_key then
        sync_horizontal_scroll(winid, existing_ctx)
        return
    end

    if existing_ctx and existing_ctx.bufnr == bufnr and existing_ctx.last_logic_key == logic_key and existing_ctx.last_context_height then
        local ctx = ensure_context_window(
            winid,
            bufnr,
            opts,
            existing_ctx.last_context_height,
            textoff,
            context_width,
            conceallevel
        )
        if not ctx then
            return
        end

        ctx.last_view_key = view_key
        sync_horizontal_scroll(winid, ctx)
        return
    end

    local context = collect_context(bufnr, opts, state, cursor, topline, cutoff)
    if not context then
        close_context_window(winid)
        return
    end

    local ctx = ensure_context_window(winid, bufnr, opts, #context.lines, textoff, context_width, conceallevel)
    if not ctx then
        return
    end

    copy_buf_option("tabstop", bufnr, ctx.context_bufnr)

    local context_key = make_context_key(context.line_numbers, context.lines, ts_ready)
    if ctx.last_context_key ~= context_key then
        set_lines(ctx.context_bufnr, context.lines)
        api.nvim_buf_clear_namespace(ctx.context_bufnr, -1, 0, -1)
        highlight_context_treesitter(bufnr, ctx.context_bufnr, context.line_numbers, context.lines)
        copy_core_extmarks(bufnr, ctx.context_bufnr, context.line_numbers)
        ctx.last_context_key = context_key
    end

    ctx.last_logic_key = logic_key
    ctx.last_context_height = #context.lines
    ctx.last_view_key = view_key
    sync_horizontal_scroll(winid, ctx)
end

local function render_buffer(bufnr)
    local state = state_by_buf[bufnr]
    if not state then
        return
    end

    cleanup_orphaned_contexts()

    if not api.nvim_buf_is_valid(bufnr) then
        M.detach(bufnr)
        return
    end

    if vim.bo[bufnr].filetype ~= "plsql" then
        close_contexts_for_buf(bufnr)
        return
    end

    local wins = {}
    for _, winid in ipairs(api.nvim_list_wins()) do
        if is_target_window(winid, bufnr) then
            local cursor = api.nvim_win_get_cursor(winid)[1]
            local topline = fn.line("w0", winid)
            local win_width = api.nvim_win_get_width(winid)
            local textoff = get_textoff(winid)
            wins[#wins + 1] = {
                winid = winid,
                cursor = cursor,
                topline = topline,
                cutoff = state.opts.mode == "topline" and topline or cursor,
                win_width = win_width,
                textoff = textoff,
                conceallevel = vim.wo[winid].conceallevel,
            }
        end
    end

    table.sort(wins, function(a, b)
        if a.cutoff == b.cutoff then
            return a.winid < b.winid
        end
        return a.cutoff < b.cutoff
    end)

    local keep = {}
    for _, win_info in ipairs(wins) do
        keep[win_info.winid] = true
        render_window(bufnr, win_info, state)
    end

    for winid, ctx in pairs(window_contexts) do
        if ctx.bufnr == bufnr and not keep[winid] then
            close_context_window(winid)
        end
    end
end

local function schedule_render(bufnr)
    local state = state_by_buf[bufnr]
    if not state or state.render_scheduled then
        return
    end

    state.render_scheduled = true
    vim.schedule(function()
        local s = state_by_buf[bufnr]
        if not s then
            return
        end

        s.render_scheduled = false
        render_buffer(bufnr)
    end)
end

function M.detach(bufnr)
    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end

    local s = state_by_buf[bufnr]
    if not s then
        return
    end

    close_contexts_for_buf(bufnr)

    if s.augroup then
        pcall(api.nvim_del_augroup_by_id, s.augroup)
    end

    state_by_buf[bufnr] = nil
end

function M.attach(bufnr, opts)
    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end

    opts = normalize_opts(opts)

    if state_by_buf[bufnr] then
        state_by_buf[bufnr].opts = opts
        schedule_render(bufnr)
        return
    end

    local augroup = api.nvim_create_augroup("PlsqlContext" .. bufnr, { clear = true })
    state_by_buf[bufnr] = {
        opts = opts,
        augroup = augroup,
        render_scheduled = false,
    }

    setup_highlights()

    api.nvim_create_autocmd({
        "CursorMoved",
        "BufWinEnter",
        "BufWinLeave",
        "BufEnter",
        "BufLeave",
        "WinEnter",
        "WinScrolled",
        "WinResized",
        "InsertLeave",
        "TextChanged",
    }, {
        buffer = bufnr,
        group = augroup,
        callback = function(args)
            if not state_by_buf[args.buf] then
                return
            end

            schedule_render(args.buf)
        end,
    })

    api.nvim_create_autocmd("BufWipeout", {
        buffer = bufnr,
        group = augroup,
        callback = function(args)
            M.detach(args.buf)
        end,
    })

    schedule_render(bufnr)
end

return M
