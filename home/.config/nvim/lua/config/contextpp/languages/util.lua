local api = vim.api

local M = {}

function M.compact(text)
    return (text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.field(node, name)
    local nodes = node:field(name)
    return nodes and nodes[1] or nil
end

function M.text(bufnr, start_node, end_node)
    local start_row, start_col = start_node:range()
    local end_row, end_col = end_node:range()
    local ok, lines = pcall(api.nvim_buf_get_text, bufnr, start_row, start_col, end_row, end_col, {})
    if not ok then
        return ""
    end

    return M.compact(table.concat(lines, " "))
end

function M.last_child(node, node_type)
    for index = node:child_count() - 1, 0, -1 do
        local child = node:child(index)
        if child and child:type() == node_type then
            return child
        end
    end
end

function M.context(node, close, label, end_row)
    if not close or label == "" then
        return
    end

    local start_row = node:range()
    local close_row, close_col = close:range()
    return {
        close_col = close_col,
        close_row = close_row,
        end_row = end_row or close_row,
        label = label,
        start_row = start_row,
    }
end

return M
