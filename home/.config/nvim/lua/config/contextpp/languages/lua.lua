local util = require("config.contextpp.languages.util")

local M = {}

local body_fields = {
    function_declaration = "body",
    function_definition = "body",
    if_statement = "consequence",
    elseif_statement = "consequence",
    else_statement = "body",
    while_statement = "body",
    for_statement = "body",
    do_statement = "body",
}

local function parent_if(node)
    local parent = node:parent()
    while parent do
        if parent:type() == "if_statement" then
            return parent
        end
        parent = parent:parent()
    end
end

local function closing_end(node)
    if node:type() == "elseif_statement" or node:type() == "else_statement" then
        node = parent_if(node)
    end
    return node and util.last_child(node, "end") or nil
end

local function label(bufnr, node, body)
    local node_type = node:type()
    if node_type == "function_definition" then
        return util.text(bufnr, node, body)
    elseif node_type == "else_statement" then
        return "else"
    elseif node_type == "do_statement" then
        return "do"
    end

    return util.text(bufnr, node, body)
end

function M.resolve(bufnr, node)
    local node_type = node:type()
    if node_type == "repeat_statement" then
        local body = util.field(node, "body")
        local condition = util.field(node, "condition")
        if not body or not condition then
            return
        end

        local body_start_row = body:range()
        local end_row = condition:range()
        if end_row <= body_start_row then
            return
        end

        return util.context(
            node,
            condition,
            "repeat until " .. util.compact(vim.treesitter.get_node_text(condition, bufnr)),
            end_row
        )
    end

    local body_field = body_fields[node_type]
    local body = body_field and util.field(node, body_field) or nil
    local close = body and closing_end(node) or nil
    if not close then
        return
    end

    local body_start_row = body:range()
    local close_row = close:range()
    if close_row <= body_start_row then
        return
    end

    local _, _, end_row = node:range()
    if node_type == "if_statement" then
        local alternative = util.field(node, "alternative")
        if alternative then
            end_row = alternative:range()
        end
    end

    return util.context(node, close, label(bufnr, node, body), end_row)
end

return M
