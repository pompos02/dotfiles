---@alias __diff_buf_id number Target buffer identifier. Default: 0 for current buffer.

---@diagnostic disable:undefined-field
---@diagnostic disable:discard-returns
---@diagnostic disable:unused-local
---@diagnostic disable:cast-local-type
---@diagnostic disable:undefined-doc-name
---@diagnostic disable:luadoc-miss-type-name

-- Module definition ==========================================================
local MiniDiff = {}
local H = {}

--- Module setup
MiniDiff.setup = function()
  -- Apply config
  H.apply_config(MiniDiff.config)

  -- Define behavior
  H.create_autocommands()
  for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
    H.auto_enable({ buf = buf_id })
  end

  -- Create default highlighting
  H.create_default_hl()
end

MiniDiff.config = {
  -- Options for how hunks are visualized
  view = {
    -- Signs used for hunks in the sign column
    -- signs = { add = '▒', change = '▒', delete = '▒' },
    signs = { add = '+', change = '~', delete = '-' },

    -- Priority of used visualization extmarks (lower than diagnostics)
    priority = 50,
  },

  -- Delays (in ms) defining asynchronous processes
  delay = {
    -- How much to wait before update following every text change
    text_change = 200,
  },

  -- Module mappings. Use `''` (empty string) to disable one.
  mappings = {
    -- Go to hunk range in corresponding direction
    goto_first = '[H',
    goto_prev = '[h',
    goto_next = ']h',
    goto_last = ']H',
  },

  -- Various options
  options = {
    -- Diff algorithm. See `:h vim.diff()`.
    algorithm = 'histogram',

    -- Whether to use "indent heuristic". See `:h vim.diff()`.
    indent_heuristic = true,

    -- The amount of second-stage diff to align lines
    linematch = 60,

    -- Whether to wrap around edges during hunk navigation
    wrap_goto = false,
  },
}
--minidoc_afterlines_end

--- Enable diff processing in buffer
---
---@param buf_id __diff_buf_id
MiniDiff.enable = function(buf_id)
  buf_id = H.validate_buf_id(buf_id)

  -- Don't enable more than once
  if H.is_buf_enabled(buf_id) or H.is_disabled(buf_id) then return end

  -- Ensure buffer is loaded (to have up to date lines returned)
  H.buf_ensure_loaded(buf_id)

  -- Register enabled buffer with cached data for performance
  H.update_buf_cache(buf_id)

  -- Add buffer watchers
  vim.api.nvim_buf_attach(buf_id, false, {
    -- Called on every text change (`:h nvim_buf_lines_event`)
    on_lines = function(_, _, _, from_line, _, to_line)
      local buf_cache = H.cache[buf_id]
      -- Properly detach if diffing is disabled
      if buf_cache == nil then return true end
      H.schedule_diff_update(buf_id, buf_cache.config.delay.text_change)
    end,

    -- Called when buffer content is changed outside of current session
    on_reload = function() H.schedule_diff_update(buf_id, 0) end,

    -- Called when buffer is unloaded from memory (`:h nvim_buf_detach_event`),
    -- **including** `:edit` command
    on_detach = function() MiniDiff.disable(buf_id) end,
  })

  -- Add buffer autocommands
  H.setup_buf_autocommands(buf_id)

  H.git_attach(buf_id)
end

--- Disable diff processing in buffer
---
---@param buf_id __diff_buf_id
MiniDiff.disable = function(buf_id)
  buf_id = H.validate_buf_id(buf_id)

  local buf_cache = H.cache[buf_id]
  if buf_cache == nil then return end
  H.cache[buf_id] = nil

  pcall(vim.api.nvim_del_augroup_by_id, buf_cache.augroup)
  H.clear_all_diff(buf_id)
  H.git_detach(buf_id)
end

--- Go to hunk range in current buffer
---
---@param direction string One of "first", "prev", "next", "last".
---@param opts table|nil Options. A table with fields:
---   - <n_times> `(number)` - Number of times to advance. Default: |v:count1|.
---   - <line_start> `(number)` - Line number to start from for directions
---     "prev" and "next". Default: cursor line.
---   - <wrap> `(boolean)` - Whether to wrap around edges.
---     Default: `options.wrap` value of the config.
MiniDiff.goto_hunk = function(direction, opts)
  local buf_id = vim.api.nvim_get_current_buf()
  local buf_cache = H.cache[buf_id]
  if buf_cache == nil then H.error(string.format('Buffer %d is not enabled.', buf_id)) end

  if not vim.tbl_contains({ 'first', 'prev', 'next', 'last' }, direction) then
    H.error('`direction` should be one of "first", "prev", "next", "last".')
  end

  local default_wrap = buf_cache.config.options.wrap_goto
  local default_opts = { n_times = vim.v.count1, line_start = vim.fn.line('.'), wrap = default_wrap }
  opts = vim.tbl_deep_extend('force', default_opts, opts or {})
  if not (type(opts.n_times) == 'number' and opts.n_times >= 1) then
    H.error('`opts.n_times` should be positive number.')
  end
  if type(opts.line_start) ~= 'number' then H.error('`opts.line_start` should be number.') end
  if type(opts.wrap) ~= 'boolean' then H.error('`opts.wrap` should be boolean.') end

  -- Prepare ranges to iterate.
  local ranges = H.get_contiguous_hunk_ranges(buf_cache.hunks)
  if #ranges == 0 then return H.notify('No hunks to go to', 'INFO') end

  -- Iterate
  local res_ind, did_wrap = H.iterate_hunk_ranges(ranges, direction, opts)
  if res_ind == nil then return H.notify('No hunk ranges in direction ' .. vim.inspect(direction), 'INFO') end
  local res_line = ranges[res_ind].from
  if did_wrap then H.notify('Wrapped around edge in direction ' .. vim.inspect(direction), 'INFO') end

  -- Add to jumplist
  vim.cmd([[normal! m']])

  -- Jump
  local _, col = vim.fn.getline(res_line):find('^%s*')
  vim.api.nvim_win_set_cursor(0, { res_line, col })

  -- Open just enough folds
  vim.cmd('normal! zv')
end

-- Helper data ================================================================
-- Timers
H.timer_diff_update = vim.loop.new_timer()

-- Namespaces per highlighter name
H.ns_id = {
  viz = vim.api.nvim_create_namespace('MiniDiffViz'),
}

-- Cache of buffers waiting for debounced diff update
H.bufs_to_update = {}

-- Cache per enabled buffer
H.cache = {}

-- Cache per buffer for attached `git` source
H.git_cache = {}

-- Flag for whether to invalidate extmarks
H.extmark_invalidate = vim.fn.has('nvim-0.10') == 1 and true or nil

-- Permanent `vim.diff()` options
H.vimdiff_opts = { result_type = 'indices', ctxlen = 0, interhunkctxlen = 0 }

-- BOM bytes prepended to buffer text if 'bomb' is enabled. See `:h bom-bytes`.
--stylua: ignore
H.bom_bytes = {
  ['utf-8']    = string.char(0xef, 0xbb, 0xbf),
  ['utf-16be'] = string.char(0xfe, 0xff),
  ['utf-16']   = string.char(0xfe, 0xff),
  ['utf-16le'] = string.char(0xff, 0xfe),
  -- In 'fileencoding', 'utf-32' is transformed into 'ucs-4'
  ['utf-32be'] = string.char(0x00, 0x00, 0xfe, 0xff),
  ['ucs-4be']  = string.char(0x00, 0x00, 0xfe, 0xff),
  ['utf-32']   = string.char(0x00, 0x00, 0xfe, 0xff),
  ['ucs-4']    = string.char(0x00, 0x00, 0xfe, 0xff),
  ['utf-32le'] = string.char(0xff, 0xfe, 0x00, 0x00),
  ['ucs-4le']  = string.char(0xff, 0xfe, 0x00, 0x00),
}

-- Helper functionality =======================================================
-- Settings -------------------------------------------------------------------
H.apply_config = function(config)
  MiniDiff.config = config

  -- Make mappings
  local mappings = config.mappings

  local goto = function(direction)
    return function() MiniDiff.goto_hunk(direction) end
  end
  H.map('n', mappings.goto_first, goto('first'), { desc = 'First hunk' })
  H.map('n', mappings.goto_prev, goto('prev'), { desc = 'Previous hunk' })
  H.map('n', mappings.goto_next, goto('next'), { desc = 'Next hunk' })
  H.map('n', mappings.goto_last, goto('last'), { desc = 'Last hunk' })

  -- Register decoration provider which actually makes visualization
  H.set_decoration_provider(H.ns_id.viz)
end

H.create_autocommands = function()
  local gr = vim.api.nvim_create_augroup('MiniDiff', {})

  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = gr, pattern = pattern, callback = callback, desc = desc })
  end

  -- NOTE: Try auto enabling buffer on every `BufEnter` to not have `:edit`
  -- disabling buffer, as it calls `on_detach()` from buffer watcher
  au('BufEnter', '*', H.auto_enable, 'Enable diff')
  au('VimResized', '*', H.on_resize, 'Track Neovim resizing')
  au('ColorScheme', '*', H.create_default_hl, 'Ensure colors')
end

--stylua: ignore
H.create_default_hl = function()
  local hi = function(name, opts)
    opts.default = true
    vim.api.nvim_set_hl(0, name, opts)
  end

  local has_core_diff_hl = vim.fn.has('nvim-0.10') == 1
  hi('MiniDiffSignAdd',        { link = has_core_diff_hl and 'Added' or 'diffAdded' })
  hi('MiniDiffSignChange',     { link = has_core_diff_hl and 'Changed' or 'diffChanged' })
  hi('MiniDiffSignDelete',     { link = has_core_diff_hl and 'Removed' or 'diffRemoved'  })
end

H.is_disabled = function(buf_id)
  local buf_disable = H.get_buf_var(buf_id, 'minidiff_disable')
  return vim.g.minidiff_disable == true or buf_disable == true
end

H.get_config = function(_buf_id)
  return MiniDiff.config
end

H.get_buf_var = function(buf_id, name)
  if not vim.api.nvim_buf_is_valid(buf_id) then return nil end
  return vim.b[buf_id or 0][name]
end

-- Autocommands ---------------------------------------------------------------
H.auto_enable = vim.schedule_wrap(function(data)
  if H.is_buf_enabled(data.buf) or H.is_disabled(data.buf) then return end
  local buf = data.buf
  if not (vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' and vim.bo[buf].buflisted) then return end
  if not H.is_buf_text(buf) then return end
  MiniDiff.enable(buf)
end)

H.on_resize = function()
  for buf_id, _ in pairs(H.cache) do
    if vim.api.nvim_buf_is_valid(buf_id) then
      H.clear_all_diff(buf_id)
      H.schedule_diff_update(buf_id, 0)
    end
  end
end

-- Validators -----------------------------------------------------------------
H.validate_buf_id = function(x)
  if x == nil or x == 0 then return vim.api.nvim_get_current_buf() end
  if not (type(x) == 'number' and vim.api.nvim_buf_is_valid(x)) then
    H.error('`buf_id` should be `nil` or valid buffer id.')
  end
  return x
end

-- Enabling -------------------------------------------------------------------
H.is_buf_enabled = function(buf_id) return H.cache[buf_id] ~= nil end

H.update_buf_cache = function(buf_id)
  local new_cache = H.cache[buf_id] or {}

  local buf_config = H.get_config(buf_id)
  new_cache.config = buf_config
  new_cache.extmark_opts = H.convert_view_to_extmark_opts(buf_config.view)

  new_cache.hunks = new_cache.hunks or {}
  new_cache.viz_lines = new_cache.viz_lines or {}

  H.cache[buf_id] = new_cache
end

H.setup_buf_autocommands = function(buf_id)
  local augroup = vim.api.nvim_create_augroup('MiniDiffBuffer' .. buf_id, { clear = true })
  H.cache[buf_id].augroup = augroup

  local buf_update = vim.schedule_wrap(function() H.update_buf_cache(buf_id) end)
  local bufwinenter_opts = { group = augroup, buffer = buf_id, callback = buf_update, desc = 'Update buffer cache' }
  vim.api.nvim_create_autocmd('BufWinEnter', bufwinenter_opts)

  local reset_if_enabled = vim.schedule_wrap(function(data)
    if not H.is_buf_enabled(data.buf) then return end
    MiniDiff.disable(data.buf)
    MiniDiff.enable(data.buf)
  end)
  local bufrename_opts = { group = augroup, buffer = buf_id, callback = reset_if_enabled, desc = 'Reset on rename' }
  -- NOTE: `BufFilePost` does not look like a proper event, but it (yet) works
  vim.api.nvim_create_autocmd('BufFilePost', bufrename_opts)

  local buf_disable = function() MiniDiff.disable(buf_id) end
  local bufdelete_opts = { group = augroup, buffer = buf_id, callback = buf_disable, desc = 'Disable on delete' }
  vim.api.nvim_create_autocmd('BufDelete', bufdelete_opts)
end

H.convert_view_to_extmark_opts = function(view)
  local signs = view.signs
  --stylua: ignore
  return {
    add =    { sign_hl_group = 'MiniDiffSignAdd',    sign_text = signs.add,    priority = view.priority, invalidate = H.extmark_invalidate },
    change = { sign_hl_group = 'MiniDiffSignChange', sign_text = signs.change, priority = view.priority, invalidate = H.extmark_invalidate },
    delete = { sign_hl_group = 'MiniDiffSignDelete', sign_text = signs.delete, priority = view.priority, invalidate = H.extmark_invalidate },
  }
end

-- Processing -----------------------------------------------------------------
H.set_decoration_provider = function(ns_id_viz)
  local on_win = function(_, _, buf_id, top, bottom)
    local buf_cache = H.cache[buf_id]
    if buf_cache == nil then return false end

    local viz_lines = buf_cache.viz_lines
    if buf_cache.needs_clear then
      H.clear_all_diff(buf_id)
      buf_cache.needs_clear, buf_cache.dummy_extmark = false, nil
      -- Ensure that sign column is visible even if hunks are outside of window
      -- view (matters with `signcolumn=auto`)
      if not vim.tbl_isempty(viz_lines) then
        local dummy_opts = { sign_text = '  ', priority = 0, right_gravity = false }
        dummy_opts.sign_hl_group, dummy_opts.cursorline_hl_group = 'SignColumn', 'CursorLineSign'
        buf_cache.dummy_extmark = vim.api.nvim_buf_set_extmark(buf_id, ns_id_viz, 0, 0, dummy_opts)
      end
    end

    local has_viz_extmarks = false
    for i = top + 1, bottom + 1 do
      if viz_lines[i] ~= nil then
        H.set_extmark(buf_id, ns_id_viz, i - 1, 0, viz_lines[i])
        viz_lines[i] = nil
        has_viz_extmarks = true
      end
    end

    -- Make sure to clear dummy extmark when it is not needed (otherwise it
    -- affects signcolumn for cases like `yes:2` and `auto:2`)
    if buf_cache.dummy_extmark ~= nil and has_viz_extmarks then
      vim.api.nvim_buf_del_extmark(buf_id, ns_id_viz, buf_cache.dummy_extmark)
      buf_cache.dummy_extmark = nil
    end
  end
  vim.api.nvim_set_decoration_provider(ns_id_viz, { on_win = on_win })
end

H.schedule_diff_update = vim.schedule_wrap(function(buf_id, delay_ms)
  H.bufs_to_update[buf_id] = true
  H.timer_diff_update:stop()
  H.timer_diff_update:start(delay_ms, 0, H.process_scheduled_buffers)
end)

H.process_scheduled_buffers = vim.schedule_wrap(function()
  for buf_id, _ in pairs(H.bufs_to_update) do
    H.update_buf_diff(buf_id)
  end
  H.bufs_to_update = {}
end)

H.update_buf_diff = vim.schedule_wrap(function(buf_id)
  -- Make early returns
  local buf_cache = H.cache[buf_id]
  if buf_cache == nil then return end
  if not vim.api.nvim_buf_is_valid(buf_id) then
    H.cache[buf_id] = nil
    return
  end
  if type(buf_cache.ref_text) ~= 'string' or H.is_disabled(buf_id) then
    buf_cache.hunks, buf_cache.viz_lines = {}, {}
    H.clear_all_diff(buf_id)
    return
  end

  -- Compute diff
  local options = buf_cache.config.options
  H.vimdiff_opts.algorithm = options.algorithm
  H.vimdiff_opts.indent_heuristic = options.indent_heuristic
  H.vimdiff_opts.linematch = options.linematch

  local buf_text = H.get_buftext(buf_id)
  local diff = vim.diff(buf_cache.ref_text, buf_text, H.vimdiff_opts)

  -- Recompute hunks and draw information
  H.update_hunk_data(diff, buf_cache)

  -- Request highlighting clear to be done in decoration provider
  buf_cache.needs_clear = true

  -- Force redraw. NOTE: Using 'redraw' not always works while 'redraw!' flickers.
  H.redraw_buffer(buf_id)
end)

H.update_hunk_data = function(diff, buf_cache)
  local extmark_opts = buf_cache.extmark_opts
  local hunks, viz_lines = {}, {}
  for i, d in ipairs(diff) do
    -- Hunk
    local n_ref, n_buf = d[2], d[4]
    local hunk_type = n_ref == 0 and 'add' or (n_buf == 0 and 'delete' or 'change')
    local hunk = { type = hunk_type, ref_start = d[1], ref_count = n_ref, buf_start = d[3], buf_count = n_buf }
    hunks[i] = hunk

    -- Register lines for draw. At least one line should visualize hunk.
    local viz_ext_opts = extmark_opts[hunk_type]
    local range_from = math.max(d[3], 1)
    local range_to = range_from + math.max(n_buf, 1) - 1
    for l_num = range_from, range_to do
      -- Prefer showing "change" hunk over other types
      if viz_lines[l_num] == nil or hunk_type == 'change' then viz_lines[l_num] = viz_ext_opts end
    end
  end

  buf_cache.hunks, buf_cache.viz_lines = hunks, viz_lines
end

H.clear_all_diff = function(buf_id)
  H.clear_namespace(buf_id, H.ns_id.viz, 0, -1)
end

-- Hunks ----------------------------------------------------------------------
H.get_hunk_buf_range = function(hunk)
  -- "Change" and "Add" hunks have the range `[from, from + buf_count - 1]`
  if hunk.buf_count > 0 then return hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 end
  -- "Delete" hunks have `buf_count = 0` yet its range is `[from, from]`
  -- `buf_start` can be 0 for 'delete' hunk, yet range should be real lines
  local from = math.max(hunk.buf_start, 1)
  return from, from
end


H.get_contiguous_hunk_ranges = function(hunks)
  if #hunks == 0 then return {} end
  hunks = vim.deepcopy(hunks)
  table.sort(hunks, H.hunk_order)

  local h1_from, h1_to = H.get_hunk_buf_range(hunks[1])
  local res = { { from = h1_from, to = h1_to } }
  for i = 2, #hunks do
    local h, cur_region = hunks[i], res[#res]
    local h_from, h_to = H.get_hunk_buf_range(h)
    if h_from <= cur_region.to + 1 then
      cur_region.to = math.max(cur_region.to, h_to)
    else
      table.insert(res, { from = h_from, to = h_to })
    end
  end
  return res
end

H.iterate_hunk_ranges = function(ranges, direction, opts)
  local n = #ranges

  -- Compute initial index
  local init_ind
  if direction == 'first' then init_ind = 0 end
  if direction == 'prev' then init_ind = H.get_range_id_prev(ranges, opts.line_start) end
  if direction == 'next' then init_ind = H.get_range_id_next(ranges, opts.line_start) end
  if direction == 'last' then init_ind = n + 1 end

  local is_on_edge = (direction == 'prev' and init_ind == 1) or (direction == 'next' and init_ind == n)
  if not opts.wrap and is_on_edge then return nil end

  -- Compute destination index
  local is_move_forward = direction == 'first' or direction == 'next'
  local res_ind = init_ind + opts.n_times * (is_move_forward and 1 or -1)
  local did_wrap = opts.wrap and (res_ind < 1 or n < res_ind)
  res_ind = opts.wrap and ((res_ind - 1) % n + 1) or math.min(math.max(res_ind, 1), n)

  return res_ind, did_wrap
end

H.get_range_id_next = function(ranges, line_start)
  for i = #ranges, 1, -1 do
    if ranges[i].from <= line_start then return i end
  end
  return 0
end

H.get_range_id_prev = function(ranges, line_start)
  for i = 1, #ranges do
    if line_start <= ranges[i].to then return i end
  end
  return #ranges + 1
end

H.hunk_order = function(a, b)
  -- Ensure buffer order and that "change" hunks are listed earlier "delete"
  -- ones from the same line.
  return a.buf_start < b.buf_start or (a.buf_start == b.buf_start and a.type == 'change')
end

-- Git ------------------------------------------------------------------------
H.set_ref_text = function(buf_id, text)
  if not H.is_buf_enabled(buf_id) then return end
  if type(text) == 'table' then text = #text > 0 and table.concat(text, '\n') or nil end
  if text ~= nil and string.sub(text, -1) ~= '\n' then text = text .. '\n' end
  H.cache[buf_id].ref_text = text
  H.schedule_diff_update(buf_id, 0)
end

H.git_attach = function(buf_id)
  if H.git_cache[buf_id] ~= nil then return end
  local path = H.get_buf_realpath(buf_id)
  if path == '' then return end
  H.git_cache[buf_id] = {}
  H.git_start_watching_index(buf_id, path)
end

H.git_detach = function(buf_id)
  local cache = H.git_cache[buf_id]
  H.git_cache[buf_id] = nil
  H.git_invalidate_cache(cache)
end

H.git_start_watching_index = function(buf_id, path)
  -- NOTE: Watching single 'index' file is not enough as staging by Git is done
  -- via "create fresh 'index.lock' file, apply modifications, change file name
  -- to 'index'". Hence watch the whole '.git' (first level) and react only if
  -- change was in 'index' file.
  local stdout = vim.loop.new_pipe()
  local args = { 'rev-parse', '--path-format=absolute', '--git-dir' }
  local spawn_opts = { args = args, cwd = vim.fn.fnamemodify(path, ':h'), stdio = { nil, stdout, nil } }

  -- If path is not in Git, stop here and keep buffer clean
  local on_not_in_git = vim.schedule_wrap(function()
    if not vim.api.nvim_buf_is_valid(buf_id) then
      H.cache[buf_id] = nil
      return
    end
    H.set_ref_text(buf_id, nil)
    H.git_cache[buf_id] = {}
  end)

  local process, stdout_feed = nil, {}
  local on_exit = function(exit_code)
    process:close()

    -- Watch index only if there was no error retrieving path to it
    if exit_code ~= 0 or stdout_feed[1] == nil then return on_not_in_git() end

    -- Set up index watching
    local git_dir_path = table.concat(stdout_feed, ''):gsub('\n+$', '')
    H.git_setup_index_watch(buf_id, git_dir_path)

    -- Set reference text immediately
    H.git_set_ref_text(buf_id)
  end

  process = vim.loop.spawn('git', spawn_opts, on_exit)
  H.git_read_stream(stdout, stdout_feed)
end

H.git_setup_index_watch = function(buf_id, git_dir_path)
  local buf_fs_event, timer = vim.loop.new_fs_event(), vim.loop.new_timer()
  local buf_git_set_ref_text = function() H.git_set_ref_text(buf_id) end

  local watch_index = function(_, filename, _)
    if filename ~= 'index' then return end
    -- Debounce to not overload during incremental staging (like in script)
    timer:stop()
    timer:start(50, 0, buf_git_set_ref_text)
  end
  buf_fs_event:start(git_dir_path, { recursive = false }, watch_index)

  H.git_invalidate_cache(H.git_cache[buf_id])
  H.git_cache[buf_id] = { fs_event = buf_fs_event, timer = timer }
end

H.git_set_ref_text = vim.schedule_wrap(function(buf_id)
  if not vim.api.nvim_buf_is_valid(buf_id) then return end
  local buf_set_ref_text = vim.schedule_wrap(function(text) H.set_ref_text(buf_id, text) end)

  -- NOTE: Do not cache buffer's name to react to its possible rename
  local path = H.get_buf_realpath(buf_id)
  if path == '' then return buf_set_ref_text(nil) end
  local cwd, basename = vim.fn.fnamemodify(path, ':h'), vim.fn.fnamemodify(path, ':t')

  -- Set
  local stdout = vim.loop.new_pipe()
  local spawn_opts = { args = { 'show', ':0:./' .. basename }, cwd = cwd, stdio = { nil, stdout, nil } }

  local process, stdout_feed = nil, {}
  local on_exit = function(exit_code)
    process:close()

    -- Unset reference text in case of any error. This results into not showing
    -- hunks at all. Possible reasons to do so:
    -- - 'Not in index' files (new, ignored, etc.).
    -- - 'Neither in index nor on disk' files (after checking out commit which
    --   does not yet have file created).
    -- - 'Relative can not be used outside working tree' (when opening file
    --   inside '.git' directory).
    if exit_code ~= 0 or stdout_feed[1] == nil then return buf_set_ref_text(nil) end

    -- Set reference text accounting for possible 'crlf' end of line in index
    local text = table.concat(stdout_feed, ''):gsub('\r\n', '\n')
    buf_set_ref_text(text)
  end

  process = vim.loop.spawn('git', spawn_opts, on_exit)
  H.git_read_stream(stdout, stdout_feed)
end)

H.git_read_stream = function(stream, feed)
  local callback = function(err, data)
    if data ~= nil then return table.insert(feed, data) end
    if err then feed[1] = nil end
    stream:close()
  end
  stream:read_start(callback)
end

H.git_invalidate_cache = function(cache)
  if cache == nil then return end
  pcall(vim.loop.fs_event_stop, cache.fs_event)
  pcall(vim.loop.timer_stop, cache.timer)
end

-- Utilities ------------------------------------------------------------------
H.error = function(msg) error('(mini.diff) ' .. msg, 0) end

H.notify = function(msg, level_name) vim.notify('(mini.diff) ' .. msg, vim.log.levels[level_name]) end

H.buf_ensure_loaded = function(buf_id)
  if type(buf_id) ~= 'number' or vim.api.nvim_buf_is_loaded(buf_id) then return end
  local cache_eventignore = vim.o.eventignore
  vim.o.eventignore = 'BufEnter,BufWinEnter'
  pcall(vim.fn.bufload, buf_id)
  vim.o.eventignore = cache_eventignore
end

H.map = function(mode, lhs, rhs, opts)
  if lhs == '' then return end
  opts = vim.tbl_deep_extend('force', { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

H.set_extmark = function(...) pcall(vim.api.nvim_buf_set_extmark, ...) end

H.clear_namespace = function(...) pcall(vim.api.nvim_buf_clear_namespace, ...) end

H.is_buf_text = function(buf_id)
  local n = vim.api.nvim_buf_call(buf_id, function() return vim.fn.byte2line(1024) end)
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, n, false)
  return table.concat(lines, ''):find('\0') == nil
end

H.get_buftext = function(buf_id)
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  -- - NOTE: Appending '\n' makes more intuitive diffs at end-of-file
  local text = table.concat(lines, '\n') .. '\n'
  if not vim.bo[buf_id].bomb then return text end
  local bytes = H.bom_bytes[vim.bo[buf_id].fileencoding] or ''
  return bytes .. text
end

-- Try getting buffer's full real path (after resolving symlinks)
H.get_buf_realpath = function(buf_id) return vim.loop.fs_realpath(vim.api.nvim_buf_get_name(buf_id)) or '' end

-- nvim__redraw replaced nvim__buf_redraw_range during the 0.10 release cycle
H.redraw_buffer = function(buf_id)
  vim.api.nvim__buf_redraw_range(buf_id, 0, -1)

  -- Redraw statusline to have possible statusline component up to date
  vim.cmd('redrawstatus')
end
if vim.api.nvim__redraw ~= nil then
  H.redraw_buffer = function(buf_id) vim.api.nvim__redraw({ buf = buf_id, valid = true, statusline = true }) end
end

MiniDiff.setup()

return MiniDiff
