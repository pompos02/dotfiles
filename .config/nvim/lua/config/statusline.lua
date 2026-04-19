local M = {}

local function escape(text)
    return (text or ""):gsub("%%", "%%%%")
end

local function join(parts)
    return table.concat(
        vim.tbl_filter(function(part)
            return part and part ~= ""
        end, parts),
        "  "
    )
end

local function format_filepath(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return "[No Name]"
    end

    return vim.fn.fnamemodify(name, ":~:.")
end

local function git_segment(bufnr)
    local status = vim.b[bufnr].gitsigns_status_dict
    if not status then
        return "", ""
    end

    local branch = status.head and status.head ~= "" and ("[" .. status.head .. "]") or ""

    local added = status.added or 0
    local changed = status.changed or 0
    local removed = status.removed or 0

    local diff = string.format(
        "[%%#SignAdd#%d %%#SignChange#%d %%#SignDelete#%d%%*]",
        added,
        changed,
        removed
    )

    return branch, diff
end

local function diagnostics_segment(bufnr)
    local counts = {
        error = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR }),
        warn = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN }),
        info = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.INFO }),
        hint = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.HINT }),
    }

    local parts = {}
    if counts.error > 0 then
        parts[#parts + 1] = "%#DiagnosticError#E:" .. counts.error
    end
    if counts.warn > 0 then
        parts[#parts + 1] = "%#DiagnosticWarn#W:" .. counts.warn
    end
    if counts.info > 0 then
        parts[#parts + 1] = "%#DiagnosticInfo#I:" .. counts.info
    end
    if counts.hint > 0 then
        parts[#parts + 1] = "%#DiagnosticHint#H:" .. counts.hint
    end

    if #parts == 0 then
        return ""
    end

    return table.concat(parts, " ") .. "%*"
end

local function lsp_segment(bufnr)
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        names[#names + 1] = client.name
    end

    local progress = vim.trim(vim.lsp.status())
    local content = join({ progress, table.concat(names, " ") })
    if content == "" then
        return ""
    end

    return content
end

function M.render()
    local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local cursor = vim.api.nvim_win_get_cursor(winid)
    local line = cursor[1]
    local col = cursor[2] + 1

    local branch, diff = git_segment(bufnr)
    local left = join({
        branch,
        escape(format_filepath(bufnr)),
        diff,
        diagnostics_segment(bufnr),
    })
    local right = join({
        escape(lsp_segment(bufnr)),
        string.format("%d:%d", line, col),
    })

    return table.concat({ " ", left, "%=", right, "  " })
end

function M.setup()
    vim.o.statusline = "%!v:lua.require('config.statusline').render()"

    local group = vim.api.nvim_create_augroup("native-statusline", { clear = true })
    vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach", "LspProgress", "ModeChanged" }, {
        group = group,
        callback = function()
            vim.cmd.redrawstatus()
        end,
    })
    vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "GitSignsUpdate", "GitSignsChanged" },
        callback = function()
            vim.cmd.redrawstatus()
        end,
    })
end

M.setup()

return M
