local api = vim.api

local M = {}

local namespace = api.nvim_create_namespace("contextpp")
local states = {}

local defaults = {
    filetypes = { "c", "cpp" },
    highlight = "Contextpp",
    prefix = "",
}

local options = vim.deepcopy(defaults)

local body_fields = {
    function_definition = "body",
    if_statement = "consequence",
    switch_statement = "body",
    while_statement = "body",
    do_statement = "body",
    for_statement = "body",
    for_range_loop = "body",
    try_statement = "body",
    catch_clause = "body",
    lambda_expression = "body",
    namespace_definition = "body",
    linkage_specification = "body",
    class_specifier = "body",
    struct_specifier = "body",
    union_specifier = "body",
    enum_specifier = "body",
}

local body_types = {
    compound_statement = true,
    declaration_list = true,
    field_declaration_list = true,
    enumerator_list = true,
}

local function is_target(bufnr)
    return vim.list_contains(options.filetypes, vim.bo[bufnr].filetype)
end

local function compact(text)
    return (text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function get_text(bufnr, start_row, start_col, end_row, end_col)
    local ok, lines = pcall(api.nvim_buf_get_text, bufnr, start_row, start_col, end_row, end_col, {})
    if not ok then
        return ""
    end

    return compact(table.concat(lines, " "))
end

local function field(node, name)
    local nodes = node:field(name)
    return nodes and nodes[1] or nil
end

local function direct_body(node)
    for child in node:iter_children() do
        if child:named() and body_types[child:type()] then
            return child
        end
    end
end

local function closing_brace(body)
    for index = body:child_count() - 1, 0, -1 do
        local child = body:child(index)
        if child and child:type() == "}" then
            return child
        end
    end
end

local function context_label(bufnr, node, body)
    if node:type() == "do_statement" then
        local condition = field(node, "condition")
        if condition then
            return "do while " .. compact(vim.treesitter.get_node_text(condition, bufnr))
        end
    elseif node:type() == "compound_statement" then
        return "block"
    end

    local start_row, start_col = node:range()
    local body_row, body_col = body:range()
    return get_text(bufnr, start_row, start_col, body_row, body_col)
end

local function context_body(node)
    local field_name = body_fields[node:type()]
    if field_name then
        return field(node, field_name)
    end

    if node:type() == "else_clause" or node:type() == "case_statement" then
        return direct_body(node)
    end

    if node:type() == "compound_statement" then
        local parent = node:parent()
        if parent and parent:type() == "compound_statement" then
            return node
        end
    end
end

local function get_context(bufnr, node, cache)
    local id = node:id()
    local cached = cache[id]
    if cached ~= nil then
        return cached or nil
    end

    local body = context_body(node)
    local close = body and closing_brace(body) or nil
    if not close then
        cache[id] = false
        return
    end

    local start_row = node:range()
    local body_start_row = body:range()
    local close_row, close_col = close:range()
    local label = context_label(bufnr, node, body)
    if close_row <= body_start_row or label == "" then
        cache[id] = false
        return
    end

    local context = {
        close_col = close_col,
        close_row = close_row,
        id = id,
        label = label,
        start_row = start_row,
    }
    cache[id] = context
    return context
end

local function active_contexts(bufnr, state, cursor_row, cursor_col)
    local active = {}
    local seen = {}
    local line = api.nvim_buf_get_lines(bufnr, cursor_row, cursor_row + 1, false)[1] or ""
    local first_nonblank = line:find("%S")
    local first_col = first_nonblank and first_nonblank - 1 or 0
    local columns = { cursor_col }
    if first_col ~= cursor_col then
        columns[#columns + 1] = first_col
    end
    if #line ~= cursor_col and #line ~= first_col then
        columns[#columns + 1] = #line
    end

    for _, column in ipairs(columns) do
        local node = state.root:named_descendant_for_range(cursor_row, column, cursor_row, column)

        while node do
            local context = get_context(bufnr, node, state.context_cache)
            if
                context
                and not seen[context.id]
                and context.start_row <= cursor_row
                and cursor_row <= context.close_row
            then
                seen[context.id] = true
                active[#active + 1] = context
            end
            node = node:parent()
        end
    end

    table.sort(active, function(left, right)
        if left.start_row ~= right.start_row then
            return left.start_row < right.start_row
        end
        if left.close_row ~= right.close_row then
            return left.close_row > right.close_row
        end
        return left.close_col > right.close_col
    end)

    return active
end

local function same_contexts(state, contexts)
    if state.rendered_tick ~= state.changedtick or #state.rendered_contexts ~= #contexts then
        return false
    end

    for index, context in ipairs(contexts) do
        if state.rendered_contexts[index] ~= context.id then
            return false
        end
    end

    return true
end

local function render(bufnr, state, contexts)
    if same_contexts(state, contexts) then
        return
    end

    api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local contexts_by_row = {}
    for _, context in ipairs(contexts) do
        contexts_by_row[context.close_row] = contexts_by_row[context.close_row] or {}
        contexts_by_row[context.close_row][#contexts_by_row[context.close_row] + 1] = context
    end

    for row, row_contexts in pairs(contexts_by_row) do
        table.sort(row_contexts, function(left, right)
            return left.close_col < right.close_col
        end)

        local labels = {}
        for _, context in ipairs(row_contexts) do
            labels[#labels + 1] = context.label
        end

        api.nvim_buf_set_extmark(bufnr, namespace, row, 0, {
            virt_text = { { options.prefix .. table.concat(labels, " "), options.highlight } },
            virt_text_pos = "eol",
            hl_mode = "combine",
        })
    end

    state.rendered_contexts = vim.tbl_map(function(context)
        return context.id
    end, contexts)
    state.rendered_tick = state.changedtick
end

local function hide(bufnr)
    local state = states[bufnr]
    if state then
        state.rendered_contexts = {}
        state.rendered_tick = nil
    end

    if api.nvim_buf_is_valid(bufnr) then
        api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    end
end

local function setup_highlight()
    -- A colorscheme-provided group takes precedence over this fallback.
    api.nvim_set_hl(0, options.highlight, { default = true, link = "Comment" })
end

function M.refresh(bufnr)
    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end
    local state = states[bufnr]
    if not state or not api.nvim_buf_is_valid(bufnr) or not api.nvim_buf_is_loaded(bufnr) then
        return
    end

    if not is_target(bufnr) then
        M.detach(bufnr)
        return
    end

    if vim.fn.mode(1):match("^[iR]") then
        hide(bufnr)
        return
    end

    local winid = vim.fn.bufwinid(bufnr)
    if winid == -1 then
        hide(bufnr)
        return
    end

    local changedtick = api.nvim_buf_get_changedtick(bufnr)
    if state.changedtick ~= changedtick then
        local language = vim.bo[bufnr].filetype
        if state.language ~= language then
            state.language = language
            state.parser = nil
        end

        if not state.parser then
            local ok, parser = pcall(vim.treesitter.get_parser, bufnr, language)
            if ok then
                state.parser = parser
            end
        end

        if not state.parser then
            hide(bufnr)
            return
        end

        local trees = state.parser:parse()
        local tree = trees and trees[1]
        if not tree then
            hide(bufnr)
            return
        end

        state.context_cache = {}
        state.root = tree:root()
        state.tree = tree
        state.changedtick = changedtick
    end

    if not state.root then
        hide(bufnr)
        return
    end

    local cursor = api.nvim_win_get_cursor(winid)
    render(bufnr, state, active_contexts(bufnr, state, cursor[1] - 1, cursor[2]))
end

local function schedule_refresh(bufnr)
    local state = states[bufnr]
    if not state or state.scheduled then
        return
    end

    state.scheduled = true
    vim.schedule(function()
        local current = states[bufnr]
        if not current then
            return
        end

        current.scheduled = false
        M.refresh(bufnr)
    end)
end

function M.attach(bufnr)
    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end
    if not api.nvim_buf_is_valid(bufnr) or not is_target(bufnr) then
        return
    end

    states[bufnr] = states[bufnr]
        or {
            changedtick = -1,
            context_cache = {},
            rendered_contexts = {},
            scheduled = false,
        }
    schedule_refresh(bufnr)
end

function M.detach(bufnr)
    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end
    states[bufnr] = nil
    hide(bufnr)
end

function M.setup(opts)
    options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
    setup_highlight()

    for _, state in pairs(states) do
        state.rendered_tick = nil
    end

    local group = api.nvim_create_augroup("Contextpp", { clear = true })
    api.nvim_create_autocmd("FileType", {
        desc = "Attach C/C++ closing-brace context",
        group = group,
        callback = function(args)
            if is_target(args.buf) then
                M.attach(args.buf)
            else
                M.detach(args.buf)
            end
        end,
    })
    api.nvim_create_autocmd({ "CursorMoved", "InsertLeave", "TextChanged", "BufEnter" }, {
        desc = "Update C/C++ closing-brace context",
        group = group,
        callback = function(args)
            schedule_refresh(args.buf)
        end,
    })
    api.nvim_create_autocmd("InsertEnter", {
        desc = "Hide C/C++ closing-brace context while inserting",
        group = group,
        callback = function(args)
            if states[args.buf] then
                hide(args.buf)
            end
        end,
    })
    api.nvim_create_autocmd("BufWipeout", {
        desc = "Detach C/C++ closing-brace context",
        group = group,
        callback = function(args)
            M.detach(args.buf)
        end,
    })
    api.nvim_create_autocmd("ColorScheme", {
        desc = "Restore contextpp highlight",
        group = group,
        callback = setup_highlight,
    })
    api.nvim_create_autocmd("User", {
        desc = "Refresh context after Tree-sitter parser updates",
        group = group,
        pattern = "TSUpdate",
        callback = function()
            for bufnr, state in pairs(states) do
                state.changedtick = -1
                state.parser = nil
                state.rendered_tick = nil
                schedule_refresh(bufnr)
            end
        end,
    })

    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_loaded(bufnr) and is_target(bufnr) then
            M.attach(bufnr)
        end
    end
end

return M
