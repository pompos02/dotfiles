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
    local file, lnum = line:match("^([^:]+):(%d+)")
    if file and lnum then
        vim.cmd("edit " .. vim.fn.fnameescape(file))
        vim.cmd("normal! " .. lnum .. "G")
        vim.cmd("normal! zz")
    end
end

function M.find_files()
    local cmd = vim.fn.executable("fd") == 1
        and "fd --type f --hidden --exclude .git"
        or "find . -type f -not -path '*/.git/*' 2>/dev/null"

    run_fzf({
        source = cmd,
        sink = "edit",
        options = "--prompt='Files> '",
    }, "files")
end

function M.live_grep(initial_query)
    local query = initial_query or ""
    if query == "" then
        query = vim.fn.input("Grep for: ")
        if query == "" then
            return
        end
    end

    local cmd
    if vim.fn.executable("rg") == 1 then
        cmd = string.format(
            "rg --line-number --no-heading --color never %s",
            vim.fn.shellescape(query)
        )
    else
        cmd = "grep -rn " .. vim.fn.shellescape(query) .. " . 2>/dev/null | grep -v '.git/'"
    end

    run_fzf({
        source = cmd,
        sink = function(item)
            jump_to_file_line(item)
        end,
        options = "--prompt='Grep> '",
    }, "live_grep")
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

function M.oldfiles()
    local items = {}
    for _, file in ipairs(vim.v.oldfiles) do
        if vim.fn.filereadable(file) == 1 then
            table.insert(items, vim.fn.fnamemodify(file, ":~:."))
            if #items >= 100 then
                break
            end
        end
    end

    if #items == 0 then
        vim.notify("No recent files", vim.log.levels.INFO)
        return
    end

    run_fzf({
        source = items,
        sink = "edit",
        options = "--prompt='Oldfiles> '",
    }, "oldfiles")
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

function M.setup() end

return M
