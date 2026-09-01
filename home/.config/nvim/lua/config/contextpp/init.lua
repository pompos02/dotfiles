local api = vim.api

local M = {}

local namespace = api.nvim_create_namespace("contextpp")
local states = {}
local enabled = false

local c_family = require("config.contextpp.languages.c_family")

local defaults = {
    enabled = true,
    highlight = "Contextpp",
    languages = {
        c = c_family,
        cpp = c_family,
        lua = require("config.contextpp.languages.lua"),
        rust = require("config.contextpp.languages.rust"),
    },
    prefix = "",
}

local options = vim.deepcopy(defaults)

local function adapter_for(bufnr)
    return options.languages[vim.bo[bufnr].filetype]
end

local function get_context(bufnr, node, state)
    local id = node:id()
    local cached = state.context_cache[id]
    if cached ~= nil then
        return cached or nil
    end

    local context = state.adapter.resolve(bufnr, node)
    if context then
        context.id = id
    end
    state.context_cache[id] = context or false
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
            local context = get_context(bufnr, node, state)
            if
                context
                and not seen[context.id]
                and context.start_row <= cursor_row
                and cursor_row <= context.end_row
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
            if left.close_col ~= right.close_col then
                return left.close_col < right.close_col
            end
            return left.start_row < right.start_row
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
    if not enabled then
        return
    end

    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end
    local state = states[bufnr]
    if not state or not api.nvim_buf_is_valid(bufnr) or not api.nvim_buf_is_loaded(bufnr) then
        return
    end

    local adapter = adapter_for(bufnr)
    if not adapter then
        M.detach(bufnr)
        return
    end

    if state.adapter ~= adapter then
        state.adapter = adapter
        state.changedtick = -1
        state.parser = nil
    end

    local language = state.adapter.parser or vim.bo[bufnr].filetype
    if state.language ~= language then
        state.language = language
        state.changedtick = -1
        state.parser = nil
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
    if not enabled then
        return
    end

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
    if not enabled then
        return
    end

    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end
    if not api.nvim_buf_is_valid(bufnr) or not adapter_for(bufnr) then
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

local function create_runtime_autocmds()
    local group = api.nvim_create_augroup("Contextpp", { clear = true })
    api.nvim_create_autocmd("FileType", {
        desc = "Attach semantic closing context",
        group = group,
        callback = function(args)
            if adapter_for(args.buf) then
                M.attach(args.buf)
            else
                M.detach(args.buf)
            end
        end,
    })
    api.nvim_create_autocmd({ "CursorMoved", "InsertLeave", "TextChanged", "BufEnter" }, {
        desc = "Update semantic closing context",
        group = group,
        callback = function(args)
            schedule_refresh(args.buf)
        end,
    })
    api.nvim_create_autocmd("InsertEnter", {
        desc = "Hide semantic closing context while inserting",
        group = group,
        callback = function(args)
            if states[args.buf] then
                hide(args.buf)
            end
        end,
    })
    api.nvim_create_autocmd("BufWipeout", {
        desc = "Detach semantic closing context",
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
end

function M.enable()
    if enabled then
        return
    end

    enabled = true
    setup_highlight()
    create_runtime_autocmds()

    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if api.nvim_buf_is_loaded(bufnr) and adapter_for(bufnr) then
            M.attach(bufnr)
        end
    end
end

function M.disable()
    if not enabled then
        return
    end

    enabled = false
    pcall(api.nvim_del_augroup_by_name, "Contextpp")

    local buffers = vim.tbl_keys(states)
    for _, bufnr in ipairs(buffers) do
        M.detach(bufnr)
    end
end

function M.toggle()
    if enabled then
        M.disable()
    else
        M.enable()
    end
end

function M.enabled()
    return enabled
end

function M.setup(opts)
    M.disable()
    options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

    api.nvim_create_user_command("ContextppEnable", M.enable, {
        desc = "Enable contextpp",
        force = true,
    })
    api.nvim_create_user_command("ContextppDisable", M.disable, {
        desc = "Disable contextpp",
        force = true,
    })
    api.nvim_create_user_command("ContextppToggle", M.toggle, {
        desc = "Toggle contextpp",
        force = true,
    })

    if options.enabled then
        M.enable()
    else
        setup_highlight()
    end
end

return M
