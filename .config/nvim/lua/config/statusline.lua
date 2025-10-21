local M = {}

local function get_git_branch()
    local head = vim.b.gitsigns_head
    if head and head ~= "" then
        return head
    end
    return ""
end

local function get_filename()
    local filename = vim.fn.expand("%:.")
    if filename == "" then
        return "[No Name]"
    end
    local modified_indicator = ""
    if vim.bo.modified then
        modified_indicator = "%#StatusLineModified#[+]%*"
    end

    return filename .. modified_indicator
end

local function get_diagnostics()
    local counts = {
        [vim.diagnostic.severity.ERROR] = 0,
        [vim.diagnostic.severity.WARN] = 0,
        [vim.diagnostic.severity.INFO] = 0,
        [vim.diagnostic.severity.HINT] = 0,
    }

    local diagnostics = vim.diagnostic.get(0)
    for _, d in ipairs(diagnostics) do
        if counts[d.severity] then
            counts[d.severity] = counts[d.severity] + 1
        end
    end

    local parts = {}
    if counts[vim.diagnostic.severity.ERROR] > 0 then
        table.insert(parts, "%#DiagnosticError#E:" .. counts[vim.diagnostic.severity.ERROR] .. "%*")
    end
    if counts[vim.diagnostic.severity.WARN] > 0 then
        table.insert(parts, "%#DiagnosticWarn#W:" .. counts[vim.diagnostic.severity.WARN] .. "%*")
    end
    if counts[vim.diagnostic.severity.INFO] > 0 then
        table.insert(parts, "%#DiagnosticInfo#I:" .. counts[vim.diagnostic.severity.INFO] .. "%*")
    end
    if counts[vim.diagnostic.severity.HINT] > 0 then
        table.insert(parts, "%#DiagnosticHint#H:" .. counts[vim.diagnostic.severity.HINT] .. "%*")
    end

    return table.concat(parts, " ")
end

local function get_git_diff()
    local gitsigns = vim.b.gitsigns_status_dict
    if not gitsigns then
        return ""
    end

    local parts = {}
    if gitsigns.added and gitsigns.added > 0 then
        table.insert(parts, "%#GitSignsAdd#+" .. gitsigns.added .. "%*")
    end
    if gitsigns.changed and gitsigns.changed > 0 then
        table.insert(parts, "%#GitSignsChange#~" .. gitsigns.changed .. "%*")
    end
    if gitsigns.removed and gitsigns.removed > 0 then
        table.insert(parts, "%#GitSignsDelete#-" .. gitsigns.removed .. "%*")
    end

    return table.concat(parts, " ")
end

local function get_lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    local names = {}

    for _, client in ipairs(clients) do
        if client.name ~= "null-ls" then
            table.insert(names, client.name)
        end
    end
    if #names == 0 then
        return ""
    end

    return table.concat(names, ":")
end

local function get_time()
    return os.date("%H:%M")
end

local function build_statusline()
    local parts = {}

    local branch = get_git_branch()
    if branch ~= "" then
        table.insert(parts, "[" .. branch .. "]")
    end

    table.insert(parts, get_filename() .. "  ")

    local diff = get_git_diff()
    if diff ~= "" then
        table.insert(parts, diff)
    end

    table.insert(parts, "%=")

    local diag = get_diagnostics()
    if diag ~= "" then
        table.insert(parts, diag .. "::")
    end

    local lsp = get_lsp_status()
    if lsp ~= "" then
        table.insert(parts, lsp .. "::")
    end

    table.insert(parts, get_time())

    return table.concat(parts, "")
end

local function setup_autocmds()
    local group = vim.api.nvim_create_augroup("CustomStatusline", { clear = true })

    vim.api.nvim_create_autocmd({
        "BufEnter",
        "BufWritePost",
        "DiagnosticChanged",
        "LspAttach",
        "LspDetach",
        "User",
    }, {
        group = group,
        callback = function()
            vim.cmd("redrawstatus")
        end,
    })

    vim.fn.timer_start(60000, function()
        vim.cmd("redrawstatus")
    end, { ["repeat"] = -1 })
end

M.build_statusline = build_statusline

M.setup = function()
    setup_autocmds()
    vim.o.statusline = "%!v:lua.require('config.statusline').build_statusline()"
    vim.o.laststatus = 3
end
return M
