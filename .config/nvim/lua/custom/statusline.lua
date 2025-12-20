local M = {}

local git_branch_cache = {}
local minidiff_cache = {}

local function read_first_line(path)
    local handle = io.open(path, "r")
    if not handle then
        return nil
    end
    local line = handle:read("*l")
    handle:close()
    return line
end

local function find_git_dir(path)
    if path == "" then
        return nil
    end
    local dir = vim.fn.fnamemodify(path, ":p:h")
    if dir == "" then
        return nil
    end
    while dir and dir ~= "" do
        local git_path = dir .. "/.git"
        local stat = vim.loop.fs_stat(git_path)
        if stat then
            if stat.type == "directory" then
                return vim.loop.fs_realpath(git_path) or git_path
            end
            if stat.type == "file" then
                local line = read_first_line(git_path)
                local gitdir = line and line:match("^gitdir:%s*(.+)$")
                if gitdir then
                    if not gitdir:match("^/") then
                        gitdir = dir .. "/" .. gitdir
                    end
                    return vim.loop.fs_realpath(gitdir) or gitdir
                end
            end
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            break
        end
        dir = parent
    end
    return nil
end

local function get_git_branch()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        return ""
    end
    local git_dir = find_git_dir(path)
    if not git_dir then
        return ""
    end
    local head_path = git_dir .. "/HEAD"
    local stat = vim.loop.fs_stat(head_path)
    local mtime = 0
    if stat and stat.mtime then
        mtime = (stat.mtime.sec * 1000000000) + stat.mtime.nsec
    end
    local cache = git_branch_cache[git_dir]
    if cache and cache.mtime == mtime then
        return cache.branch or ""
    end
    local head = read_first_line(head_path)
    local branch = ""
    if head then
        local ref = head:match("^ref:%s*(.+)$")
        if ref then
            branch = ref:match("^refs/heads/(.+)$") or ref
        end
    end
    git_branch_cache[git_dir] = { branch = branch, mtime = mtime }
    return branch
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

local function get_minidiff_state(buf_id)
    -- Reach into MiniDiff internals to reuse its computed hunks without extra git work.
    if minidiff_cache.state == nil then
        local ok, minidiff = pcall(require, "custom.git-diff")
        if ok and type(minidiff) == "table" and type(minidiff.enable) == "function" then
            if debug and type(debug.getupvalue) == "function" then
                local i = 1
                while true do
                    local name, value = debug.getupvalue(minidiff.enable, i)
                    if not name then
                        break
                    end
                    if name == "H" and type(value) == "table" then
                        minidiff_cache.state = value
                        break
                    end
                    i = i + 1
                end
            end
        end
    end
    if type(minidiff_cache.state) ~= "table" then
        return nil
    end
    return minidiff_cache.state.cache and minidiff_cache.state.cache[buf_id] or nil
end

local function get_git_diff()
    local buf_id = vim.api.nvim_get_current_buf()
    local state = get_minidiff_state(buf_id)
    if not state or type(state.hunks) ~= "table" or state.ref_text == nil then
        return ""
    end

    local summary = { add = 0, change = 0, delete = 0 }
    for _, hunk in ipairs(state.hunks) do
        if hunk.type == "add" then
            summary.add = summary.add + (hunk.buf_count or 0)
        elseif hunk.type == "change" then
            local ref = hunk.ref_count or 0
            local buf = hunk.buf_count or 0
            summary.change = summary.change + math.max(ref, buf)
        elseif hunk.type == "delete" then
            summary.delete = summary.delete + (hunk.ref_count or 0)
        end
    end

    if summary.add == 0 and summary.change == 0 and summary.delete == 0 then
        return ""
    end

    local parts = {}
    if summary.add > 0 then
        table.insert(parts, "%#MiniDiffSignAdd#+" .. summary.add .. "%*")
    end
    if summary.change > 0 then
        table.insert(parts, "%#MiniDiffSignChange#~" .. summary.change .. "%*")
    end
    if summary.delete > 0 then
        table.insert(parts, "%#MiniDiffSignDelete#-" .. summary.delete .. "%*")
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

local function setup_statusline_colors()
    local cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })

    vim.api.nvim_set_hl(0, "StatusLine", {
        bg = cursorline.bg or normal.bg,
        fg = normal.fg,
    })

    vim.api.nvim_set_hl(0, "StatusLineNC", {
        bg = cursorline.bg or normal.bg,
        fg = normal.fg,
    })
end

M.setup = function()
    setup_autocmds()
    setup_statusline_colors()
    vim.o.statusline = "%!v:lua.require('custom.statusline').build_statusline()"
    vim.o.laststatus = 3

    -- Reapply colors when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("StatuslineColors", { clear = true }),
        callback = setup_statusline_colors,
    })
end
return M
