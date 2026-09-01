local util = require("config.contextpp.languages.util")

local M = {}

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

local function direct_body(node)
    for child in node:iter_children() do
        if child:named() and body_types[child:type()] then
            return child
        end
    end
end

local function context_body(node)
    local field_name = body_fields[node:type()]
    if field_name then
        return util.field(node, field_name)
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

function M.resolve(bufnr, node)
    local body = context_body(node)
    local close = body and util.last_child(body, "}") or nil
    if not close then
        return
    end

    local body_start_row = body:range()
    local close_row = close:range()
    if close_row <= body_start_row then
        return
    end

    local label
    if node:type() == "do_statement" then
        local condition = util.field(node, "condition")
        if condition then
            label = "do while " .. util.compact(vim.treesitter.get_node_text(condition, bufnr))
        end
    elseif node:type() == "compound_statement" then
        label = "block"
    else
        label = util.text(bufnr, node, body)
    end

    return util.context(node, close, label or "")
end

return M
