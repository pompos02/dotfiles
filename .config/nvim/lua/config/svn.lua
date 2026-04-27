---@class SvnConfigModule
---@field setup fun()
local M = {}

---@class SvnSignPlacement
---@field name string
---@field lnum integer

-- Configure SVN-based gutter signs for normal file buffers.
--
-- The module compares the current buffer contents against the repository copy
-- reported by `svn cat`, then places signs that mirror the basic add/change/
---@return nil
function M.setup()
    do
        local group = "SvnSigns"
        local sign_group = "svn_signs"

        vim.fn.sign_define("SvnSignAdd", { text = "▎", texthl = "GitSignsAdd" })
        vim.fn.sign_define("SvnSignChange", { text = "▎", texthl = "GitSignsChange" })
        vim.fn.sign_define("SvnSignDelete", { text = "", texthl = "GitSignsDelete" })
        vim.fn.sign_define("SvnSignChangeDelete", { text = "▎", texthl = "GitSignsChange" })

        ---@class SvnBufferState
        ---@field pending boolean
        ---@field pending_refresh_meta boolean
        ---@field running boolean
        ---@field rerun boolean
        ---@field rerun_refresh_meta boolean
        ---@field file string|nil
        ---@field root string|false|nil
        ---@field status string|nil
        ---@field base_text string|nil
        ---@field meta_ready boolean
        ---@field last_sign_key string|nil
        ---@type table<integer, SvnBufferState>
        local state = {}

        ---@param bufnr integer
        ---@return SvnBufferState
        local function get_state(bufnr)
            local buf_state = state[bufnr]
            if buf_state then
                return buf_state
            end

            buf_state = {
                pending = false,
                pending_refresh_meta = false,
                running = false,
                rerun = false,
                rerun_refresh_meta = false,
                file = nil,
                root = nil,
                status = nil,
                base_text = nil,
                meta_ready = false,
                last_sign_key = nil,
            }
            state[bufnr] = buf_state
            return buf_state
        end

        -- Ignore special buffers; the diff flow only makes sense for real files.
        ---@param bufnr integer
        ---@return boolean
        local function is_file_buffer(bufnr)
            return vim.api.nvim_buf_is_valid(bufnr)
                and vim.bo[bufnr].buftype == ""
                and vim.api.nvim_buf_get_name(bufnr) ~= ""
        end

        -- Walk upward from the file to find the checkout root that owns `.svn`.
        ---@param path string
        ---@return string|nil
        local function find_svn_root(path)
            local dir = vim.fs.dirname(path)
            local found = vim.fs.find(".svn", { path = dir, upward = true, type = "directory" })[1]
            return found and vim.fs.dirname(found) or nil
        end

        ---@param cmd string[]
        ---@param opts? vim.SystemOpts
        ---@param callback fun(code: integer, stdout: string, stderr: string)
        local function run(cmd, opts, callback)
            local run_opts = vim.tbl_extend("force", { text = true }, opts or {})
            local ok, err = pcall(function()
                vim.system(cmd, run_opts, function(obj)
                    vim.schedule(function()
                        callback(obj.code, obj.stdout or "", obj.stderr or "")
                    end)
                end)
            end)

            if ok then
                return
            end

            vim.schedule(function()
                callback(1, "", tostring(err))
            end)
        end

        ---@param bufnr integer
        local function clear_signs(bufnr)
            vim.fn.sign_unplace(sign_group, { buffer = bufnr })
        end

        ---@param bufnr integer
        ---@param id integer
        ---@param name string
        ---@param lnum integer
        local function place_sign(bufnr, id, name, lnum)
            vim.fn.sign_place(id, sign_group, name, bufnr, { lnum = lnum, priority = 10 })
        end

        ---@param buf_state SvnBufferState
        local function reset_meta(buf_state)
            buf_state.status = nil
            buf_state.base_text = nil
            buf_state.meta_ready = false
        end

        ---@param buf_state SvnBufferState
        ---@param file string
        local function reset_file_cache(buf_state, file)
            if buf_state.file == file then
                return
            end

            buf_state.file = file
            buf_state.root = nil
            buf_state.last_sign_key = nil
            reset_meta(buf_state)
        end

        ---@param bufnr integer
        ---@return string
        local function get_buffer_text(bufnr)
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local text = table.concat(lines, "\n")
            if vim.api.nvim_get_option_value("eol", { buf = bufnr }) then
                text = text .. "\n"
            end
            return text
        end

        ---@param buf_state SvnBufferState
        ---@param placements SvnSignPlacement[]
        ---@return boolean
        local function set_signs(bufnr, buf_state, placements)
            local key_parts = {}
            for i, placement in ipairs(placements) do
                key_parts[i] = placement.name .. ":" .. placement.lnum
            end

            local key = table.concat(key_parts, "|")
            if buf_state.last_sign_key == key then
                return false
            end

            buf_state.last_sign_key = key
            clear_signs(bufnr)
            for i, placement in ipairs(placements) do
                place_sign(bufnr, i, placement.name, placement.lnum)
            end
            return true
        end

        ---@param hunks integer[][]|nil
        ---@return SvnSignPlacement[]
        local function build_signs(hunks)
            ---@type SvnSignPlacement[]
            local placements = {}

            ---@param name string
            ---@param lnum integer
            local function add(name, lnum)
                placements[#placements + 1] = { name = name, lnum = lnum }
            end

            for _, hunk in ipairs(hunks or {}) do
                local old_line = hunk[1]
                local old_count = hunk[2]
                local new_line = hunk[3]
                local new_count = hunk[4]

                -- Convert zero-context diff hunks into gutter signs for the current buffer.
                if old_count == 0 and new_count > 0 then
                    for offset = 0, new_count - 1 do
                        add("SvnSignAdd", new_line + offset)
                    end
                elseif old_count > 0 and new_count == 0 then
                    add("SvnSignDelete", new_line == 0 and 1 or new_line)
                elseif old_count == new_count then
                    for offset = 0, new_count - 1 do
                        add("SvnSignChange", new_line + offset)
                    end
                elseif old_count < new_count then
                    for offset = 0, old_count - 1 do
                        add("SvnSignChange", new_line + offset)
                    end
                    for offset = old_count, new_count - 1 do
                        add("SvnSignAdd", new_line + offset)
                    end
                else
                    -- Pure deletions in a reduced replacement hunk have no current line to mark.
                    add("SvnSignDelete", new_line > 1 and (new_line - 1) or 1)
                    for offset = 0, new_count - 1 do
                        add("SvnSignChange", new_line + offset)
                    end
                end
            end

            return placements
        end

        ---@param bufnr integer
        ---@param file string
        ---@param tick integer
        ---@return boolean
        local function is_stale(bufnr, file, tick)
            return not is_file_buffer(bufnr)
                or vim.api.nvim_buf_get_name(bufnr) ~= file
                or vim.api.nvim_buf_get_changedtick(bufnr) ~= tick
        end

        local schedule

        ---@param bufnr integer
        local function finish(bufnr)
            local buf_state = state[bufnr]
            if not buf_state then
                return
            end

            buf_state.running = false

            if not vim.api.nvim_buf_is_valid(bufnr) then
                state[bufnr] = nil
                return
            end

            if not buf_state.rerun then
                return
            end

            local refresh_meta = buf_state.rerun_refresh_meta
            buf_state.rerun = false
            buf_state.rerun_refresh_meta = false
            schedule(bufnr, { refresh_meta = refresh_meta })
        end

        ---@param bufnr integer
        ---@param buf_state SvnBufferState
        local function apply_cached_diff(bufnr, buf_state)
            local status = buf_state.status or ""

            if status == "?" or status == "I" then
                set_signs(bufnr, buf_state, {})
                return
            end

            if status == "A" then
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                ---@type SvnSignPlacement[]
                local placements = {}
                for i = 1, line_count do
                    placements[#placements + 1] = { name = "SvnSignAdd", lnum = i }
                end
                set_signs(bufnr, buf_state, placements)
                return
            end

            local hunks = vim.text.diff(buf_state.base_text or "", get_buffer_text(bufnr), {
                result_type = "indices",
            })
            set_signs(bufnr, buf_state, build_signs(hunks))
        end

        -- Refresh one buffer by asking SVN for status/base content and diffing it
        -- against the live buffer contents, including unsaved edits. Most edit
        -- events reuse cached SVN state and only recompute the local diff.
        ---@param bufnr integer
        ---@param opts? { refresh_meta?: boolean }
        local function update(bufnr, opts)
            if not is_file_buffer(bufnr) then
                return
            end

            local buf_state = get_state(bufnr)
            if buf_state.running then
                buf_state.rerun = true
                buf_state.rerun_refresh_meta = buf_state.rerun_refresh_meta or (opts and opts.refresh_meta) or false
                return
            end
            buf_state.running = true

            local file = vim.api.nvim_buf_get_name(bufnr)
            reset_file_cache(buf_state, file)

            if opts and opts.refresh_meta then
                reset_meta(buf_state)
                if buf_state.root == false then
                    buf_state.root = nil
                end
            end

            local tick = vim.api.nvim_buf_get_changedtick(bufnr)
            if buf_state.root == nil then
                buf_state.root = find_svn_root(file) or false
            end

            if buf_state.root == false then
                set_signs(bufnr, buf_state, {})
                finish(bufnr)
                return
            end

            if buf_state.meta_ready then
                apply_cached_diff(bufnr, buf_state)
                finish(bufnr)
                return
            end

            run({ "svn", "status", file }, { cwd = buf_state.root }, function(status_code, status_out)
                if is_stale(bufnr, file, tick) then
                    buf_state.rerun = true
                    finish(bufnr)
                    return
                end

                if status_code ~= 0 then
                    reset_meta(buf_state)
                    set_signs(bufnr, buf_state, {})
                    finish(bufnr)
                    return
                end

                buf_state.status = status_out:match("^(.).*") or ""
                if buf_state.status == "?" or buf_state.status == "I" then
                    buf_state.base_text = nil
                    buf_state.meta_ready = true
                    set_signs(bufnr, buf_state, {})
                    finish(bufnr)
                    return
                end

                if buf_state.status == "A" then
                    buf_state.base_text = nil
                    buf_state.meta_ready = true
                    apply_cached_diff(bufnr, buf_state)
                    finish(bufnr)
                    return
                end

                run({ "svn", "cat", "-r", "BASE", file }, { cwd = buf_state.root }, function(cat_code, base_out)
                    if is_stale(bufnr, file, tick) then
                        buf_state.rerun = true
                        finish(bufnr)
                        return
                    end

                    if cat_code ~= 0 then
                        reset_meta(buf_state)
                        set_signs(bufnr, buf_state, {})
                        finish(bufnr)
                        return
                    end

                    buf_state.base_text = base_out
                    buf_state.meta_ready = true
                    apply_cached_diff(bufnr, buf_state)
                    finish(bufnr)
                end)
            end)
        end

        -- Coalesce bursty buffer events into a single refresh per buffer.
        ---@param bufnr integer
        ---@param opts? { refresh_meta?: boolean }
        schedule = function(bufnr, opts)
            local buf_state = get_state(bufnr)
            local refresh_meta = (opts and opts.refresh_meta) or false
            if buf_state.pending then
                buf_state.pending_refresh_meta = buf_state.pending_refresh_meta or refresh_meta
                return
            end
            if buf_state.running then
                buf_state.rerun = true
                buf_state.rerun_refresh_meta = buf_state.rerun_refresh_meta or refresh_meta
                return
            end

            buf_state.pending = true
            buf_state.pending_refresh_meta = refresh_meta
            -- Debounce edits so frequent TextChanged events do not spawn overlapping SVN work.
            vim.defer_fn(function()
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    state[bufnr] = nil
                    return
                end

                local latest_state = get_state(bufnr)
                latest_state.pending = false
                local pending_refresh_meta = latest_state.pending_refresh_meta
                latest_state.pending_refresh_meta = false
                update(bufnr, { refresh_meta = pending_refresh_meta })
            end, 120)
        end

        -- Manual escape hatch when signs need an explicit refresh.
        vim.api.nvim_create_user_command("SvnSignsRefresh", function()
            schedule(vim.api.nvim_get_current_buf(), { refresh_meta = true })
        end, {})

        -- Keep signs updated while entering buffers, writing files, and editing.
        vim.api.nvim_create_augroup(group, { clear = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
            group = group,
            callback = function(args)
                schedule(args.buf)
            end,
        })
        vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
            group = group,
            callback = function(args)
                schedule(args.buf, { refresh_meta = true })
            end,
        })
        vim.api.nvim_create_autocmd("BufWipeout", {
            group = group,
            callback = function(args)
                state[args.buf] = nil
            end,
        })
    end
end

return M
