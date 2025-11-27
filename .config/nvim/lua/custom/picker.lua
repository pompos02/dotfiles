-- Simple fzf-based pickers without external Lua dependencies

local M = {}

local function has_fzf()
   return vim.fn.exists("*fzf#run") == 1 and vim.fn.exists("*fzf#wrap") == 1
end

local function run_fzf(spec, name, fullscreen)
    if not has_fzf() then
        vim.notify("fzf.vim is not available on runtimepath", vim.log.levels.ERROR)
        return
    end

    local wrap = vim.fn["fzf#wrap"]
    local run = vim.fn["fzf#run"]

    local wrapped
    if name then
        wrapped = wrap(name, spec, fullscreen and 1 or 0)
    else
        wrapped = wrap(spec, nil, fullscreen and 1 or 0)
    end

    run(wrapped)
end

local function jump_to_file_line(line)
    -- strip ANSI color codes so file:line parsing remains valid when sources are colored
    line = line:gsub("\27%[[0-9;]*m", "")
    local file, lnum = line:match("^([^:]+):(%d+)")
    if file and lnum then
        vim.cmd("edit " .. vim.fn.fnameescape(file))
        vim.cmd("normal! " .. lnum .. "G")
        vim.cmd("normal! zz")
    end
end

local function parse_grep_line(line)
    line = line:gsub("\27%[[0-9;]*m", "")
    local file, lnum, col, text = line:match("^([^:]+):(%d+):?(%d*):(.*)$")
    if not (file and lnum) then
        return nil
    end
    return {
        filename = file,
        lnum = tonumber(lnum),
        col = col ~= "" and tonumber(col) or nil,
        text = vim.trim(text or ""),
    }
end

function M.find_files()
    local cmd = vim.fn.executable("fd") == 1
        and "fd --type f --hidden --exclude .git"
        or "find . -type f -not -path '*/.git/*' 2>/dev/null"
    run_fzf({
        source = cmd,
        sink = "edit",
        options = {
            "--prompt=Files> ",
        },
    }, "files")
end


function M.live_grep(initial_query)
    local query = initial_query or ""

    local has_rg = vim.fn.executable("rg") == 1

    local function reload_cmd(q)
        if has_rg then
            return string.format(
                "rg --line-number  --hidden --glob='!.git/**' --color=never -- %s",
                vim.fn.shellescape(q)
            )
        else
            return string.format(
                "grep --color=never -rn --include='.*' --include='*' --exclude-dir=.git %s . 2>/dev/null",
                vim.fn.shellescape(q)
            )
        end
    end

    local initial_source = query ~= "" and reload_cmd(query) or "printf ''"

    run_fzf({
        source = initial_source,
        sinklist = function(lines)
            if #lines == 0 then
                return
            end

            local key = lines[1]
            local items = {}
            local start_idx = key ~= "" and 2 or 1

            for i = start_idx, #lines do
                local entry = parse_grep_line(lines[i])
                if entry then
                    table.insert(items, entry)
                end
            end

            if key == "ctrl-q" then
                if #items == 0 then
                    vim.notify("No entries to add to quickfix", vim.log.levels.INFO)
                    return
                end
                vim.fn.setqflist({}, "r", { items = items })
                vim.cmd.copen()
                return
            end

            if items[1] then
                jump_to_file_line(string.format("%s:%d", items[1].filename, items[1].lnum))
            end
        end,
        options = {
            "--ansi",
            "--prompt=Grep> ",
            "--delimiter=:",
            "--preview",
            has_rg
                and "rg --color=always --line-number  --hidden --glob='!.git/**' --context 5 -- {q} {1}"
                or "grep --color=always -n -C4 --include='.*' --include='*' --exclude-dir=.git -- {q} {1}",
            "--preview-window=right:60%",
            "--bind", string.format("change:reload:%s", reload_cmd("{q}")),
            "--phony",
            "--expect=ctrl-q",
            "--multi",
            "--bind=ctrl-a:select-all,ctrl-d:deselect-all",
            query ~= "" and ("--query=" .. query) or nil,
        },
    }, "live_grep_live")
end

function M.buffers()
    local items = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name ~= "" then
                local display = vim.fn.fnamemodify(name, ":~:.")
                local modified = vim.bo[buf].modified and " [+]" or ""
                table.insert(items, string.format("%d: %s%s", buf, display, modified))
            end
        end
    end

    if #items == 0 then
        vim.notify("No buffers to show", vim.log.levels.INFO)
        return
    end

    run_fzf({
        source = items,
        sink = function(line)
            local bufnum = line:match("^(%d+):")
            if bufnum then
                vim.cmd("buffer " .. bufnum)
            end
        end,
        options = "--prompt='Buffers> '",
    }, "buffers")
end

function M.help_tags()
    local tags = {}
    local files = vim.api.nvim_get_runtime_file("doc/tags", true)
    for _, file in ipairs(files) do
        local f = io.open(file, "r")
        if f then
            for line in f:lines() do
                local tag = line:match("^([^\t]+)")
                if tag then
                    table.insert(tags, tag)
                end
            end
            f:close()
        end
    end

    if #tags == 0 then
        vim.notify("No help tags found", vim.log.levels.INFO)
        return
    end

    run_fzf({
        source = tags,
        sink = function(tag)
            vim.cmd("help " .. tag)
        end,
        options = "--prompt='Help> '",
    }, "help_tags")
end

local keymap_modes = {
    { "n", "NORMAL" },
    { "i", "INSERT" },
    { "v", "VISUAL" },
    { "x", "VISUAL-BLOCK" },
    { "s", "SELECT" },
    { "o", "OPERATOR" },
    { "c", "COMMAND" },
    { "t", "TERMINAL" },
}

local function format_map(mode, scope, map)
    local lhs = map.lhs or map.lhsraw or ""
    local desc = map.desc
    local rhs = map.rhs or ""

    local label
    if desc and desc ~= "" then
        label = desc
    elseif rhs ~= "" then
        label = rhs
    elseif map.callback then
        label = "<lua>"
    else
        label = "<mapping>"
    end

    return string.format("%-6s %-6s %-20s %s", mode, scope, lhs, label)
end

function M.keymaps()
    local items = {}

    for _, mode in ipairs(keymap_modes) do
        for _, map in ipairs(vim.api.nvim_get_keymap(mode[1])) do
            table.insert(items, format_map(mode[2], "global", map))
        end
        for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode[1])) do
            table.insert(items, format_map(mode[2], "buffer", map))
        end
    end

    if #items == 0 then
        vim.notify("No keymaps found", vim.log.levels.INFO)
        return
    end

    run_fzf({
        source = items,
        sink = function(line)
            vim.notify(line, vim.log.levels.INFO)
        end,
        options = "--prompt='Keys> '",
    }, "keymaps")
end


return M
