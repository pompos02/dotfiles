local util = require("config.contextpp.languages.util")

local M = {}

local body_fields = {
    function_item = "body",
    mod_item = "body",
    impl_item = "body",
    trait_item = "body",
    struct_item = "body",
    enum_item = "body",
    union_item = "body",
    foreign_mod_item = "body",
    if_expression = "consequence",
    while_expression = "body",
    for_expression = "body",
    loop_expression = "body",
    match_expression = "body",
    closure_expression = "body",
    let_declaration = "alternative",
}

local direct_block_types = {
    unsafe_block = true,
    async_block = true,
    try_block = true,
}

local function direct_block(node)
    for child in node:iter_children() do
        if child:named() and child:type() == "block" then
            return child
        end
    end
end

local function context_body(node)
    local field_name = body_fields[node:type()]
    if field_name then
        return util.field(node, field_name)
    end

    if node:type() == "else_clause" then
        return direct_block(node)
    end

    if node:type() == "match_arm" then
        local value = util.field(node, "value")
        if value and value:type() == "block" then
            return value
        end
    end

    if node:type() == "block" then
        local parent = node:parent()
        local grandparent = parent and parent:parent() or nil
        if parent and parent:type() == "expression_statement" and grandparent and grandparent:type() == "block" then
            return node
        end
    end

    if direct_block_types[node:type()] then
        return direct_block(node)
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
    if node:type() == "else_clause" then
        label = "else"
    elseif node:type() == "unsafe_block" then
        label = "unsafe"
    elseif node:type() == "async_block" then
        label = "async"
    elseif node:type() == "try_block" then
        label = "try"
    elseif node:type() == "block" then
        label = "block"
    else
        label = util.text(bufnr, node, body)
    end

    return util.context(node, close, label)
end

return M
