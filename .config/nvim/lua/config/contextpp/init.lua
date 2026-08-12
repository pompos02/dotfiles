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

local function collect_contexts(bufnr, root)
    local contexts = {}

    local function visit(node, depth)
        local body = context_body(node)
        if body then
            local close = closing_brace(body)
            if close then
                local start_row = node:range()
                local body_start_row = body:range()
                local close_row = close:range()
                local label = context_label(bufnr, node, body)

                if close_row > body_start_row and label ~= "" then
                    contexts[#contexts + 1] = {
                        close_row = close_row,
                        depth = depth,
                        label = label,
                        start_row = start_row,
                    }
                end
            end
        end

        for child in node:iter_children() do
            if child:named() then
                visit(child, depth + 1)
            end
        end
    end

    visit(root, 0)
    return contexts
end

local function render(bufnr, contexts, cursor_row)
    api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local closest
    for _, context in ipairs(contexts) do
        if context.start_row <= cursor_row and cursor_row <= context.close_row then
            if not closest or context.depth > closest.depth then
                closest = context
            end
        end
    end

    if closest then
        api.nvim_buf_set_extmark(bufnr, namespace, closest.close_row, 0, {
            virt_text = { { options.prefix .. closest.label, options.highlight } },
            virt_text_pos = "eol",
            hl_mode = "combine",
        })
    end
end

local function hide(bufnr)
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
        local ok, parser = pcall(vim.treesitter.get_parser, bufnr, language)
        if not ok or not parser then
            hide(bufnr)
            return
        end

        local trees = parser:parse()
        local tree = trees and trees[1]
        if not tree then
            hide(bufnr)
            return
        end

        state.contexts = collect_contexts(bufnr, tree:root())
        state.changedtick = changedtick
    end

    local cursor_row = api.nvim_win_get_cursor(winid)[1] - 1
    render(bufnr, state.contexts or {}, cursor_row)
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

    states[bufnr] = states[bufnr] or {
        changedtick = -1,
        contexts = {},
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
