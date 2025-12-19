-- This module highlights reference usages and the corresponding
-- definition on cursor hold.

local api = vim.api
local uv = vim.uv or vim.loop

-- Opinionated defaults (no configuration exposed)
local HLGROUP = 'LocalHighlight'
local CW_HLGROUP = HLGROUP
local DEBOUNCE_TIMEOUT = 100
local INSERT_MODE = false
local MIN_MATCH_LEN = 1
local MAX_MATCH_LEN = math.huge
local HIGHLIGHT_SINGLE_MATCH = true

local M = {
  regexes = {
    cache = {},
    order = {},
  },
  timing_info = {},
  usage_count = 0,
  debug_print_usage_every_time = false,
  last_cache = {},
  last_count = {},
  debounce_timer = nil,
}

local usage_namespace = api.nvim_create_namespace('highlight_usages_in_window')

local function all_matches(bufnr, regex, line)
  local ans = {}
  local offset = 0
  while true do
    local s, ss, e = pcall(regex.match_line, regex, bufnr, line, offset)
    if not s or not ss then
      return ans
    end
    table.insert(ans, ss + offset)
    offset = offset + e
  end
end

function M.stats()
  local avg_time = 0
  for _, t in ipairs(M.timing_info) do
    avg_time = avg_time + t
  end
  local count = #M.timing_info
  return string.format(
    [[
Total Usage Count    : %d
Average Running Time : %f msec
  ]],
    M.usage_count,
    count > 0 and avg_time / count or 0
  )
end

function M.regex(pattern)
  local ret = M.regexes.cache[pattern]
  if ret ~= nil then
    return ret
  end
  ret = vim.regex(pattern)
  if #M.regexes.order > 1000 then
    local last = table.remove(M.regexes.order, 1)
    M.regexes.cache[last] = nil
  end
  M.regexes.cache[pattern] = ret
  table.insert(M.regexes.order, ret)

  return ret
end

function M.highlight_usages(bufnr)
  local start_time = vim.fn.reltime()
  local cursor = api.nvim_win_get_cursor(0)
  local line = vim.fn.getline('.')
  if string.sub(line, cursor[2] + 1, cursor[2] + 1) == ' ' then
    M.clear_highlights(bufnr)
    M.last_cache[bufnr] = nil
    return
  end
  local curword, curword_start, curword_end = unpack(vim.fn.matchstrpos(line, [[\k*\%]] .. cursor[2] + 1 .. [[c\k*]]))
  if not curword or #curword < MIN_MATCH_LEN or #curword > MAX_MATCH_LEN then
    M.clear_highlights(bufnr)
    M.last_cache[bufnr] = nil
    return
  end
  local topline, botline = vim.fn.line('w0') - 1, vim.fn.line('w$')
  -- Don't calculate usages again if we are on the same word.
  local prev_cache = M.last_cache[bufnr]
  local is_new_curword = false
  if M.last_cache[bufnr] and curword == M.last_cache[bufnr].curword and topline == M.last_cache[bufnr].topline and botline == M.last_cache[bufnr].botline and cursor[1] == M.last_cache[bufnr].row and cursor[2] >= M.last_cache[bufnr].col_start and cursor[2] <= M.last_cache[bufnr].col_end and M.has_highlights(bufnr) then
    return
  else
    M.last_cache[bufnr] = {
      curword = curword,
      topline = topline,
      botline = botline,
      row = cursor[1],
      col_start = curword_start,
      col_end = curword_end,
      matches = {},
    }
    if prev_cache and curword == prev_cache.curword then
      is_new_curword = true
    end
  end

  local current_cache = M.last_cache[bufnr]

  -- dumb find all matches of the word
  -- matching whole word ('\<' and '\>')
  local cursor_range = { cursor[1] - 1, cursor[2] }
  local curpattern = string.format([[\V\<%s\>]], curword)
  local curpattern_len = #curword
  local status, regex = pcall(M.regex, curpattern)
  if not status then
    return
  end

  -- if this is a new word, phase out all previous matches
  if prev_cache and not is_new_curword then
    M.clear_highlights(bufnr)
    prev_cache = nil
  end

  local total_matches = 0
  for row = topline, botline - 1 do
    local matches = all_matches(bufnr, regex, row)
    for _, col in ipairs(matches) do
      total_matches = total_matches + 1
      local hash = row .. '_' .. col
      local is_curword = (row == cursor_range[1] and cursor_range[2] >= col and cursor_range[2] <= col + curpattern_len)
      local hl_group = HLGROUP
      if is_curword then
        hl_group = CW_HLGROUP
      end
      local existing = prev_cache and prev_cache.matches[hash]
      local id = api.nvim_buf_set_extmark(bufnr, usage_namespace, row, col, {
        id = existing and existing.id or nil,
        end_row = row,
        end_col = col + curpattern_len,
        hl_group = hl_group,
        priority = 200,
        strict = false,
      })
      current_cache.matches[hash] = {
        id = id,
      }
    end
  end

  if not HIGHLIGHT_SINGLE_MATCH and total_matches <= 1 then
    M.clear_highlights(bufnr)
    return
  end

  M.last_count[bufnr] = total_matches

  local time_since_start = vim.fn.reltimefloat(vim.fn.reltime(start_time)) * 1000
  if M.debug_print_usage_every_time then
    api.nvim_echo({ { string.format('LH: %f', time_since_start) } }, false, {})
  end
  table.insert(M.timing_info, time_since_start)
  M.usage_count = M.usage_count + 1
end

function M.match_count(bufnr)
  if (bufnr or 0) == 0 then
    bufnr = vim.fn.bufnr()
  end
  return M.last_count[bufnr] or 0
end

function M.has_highlights(bufnr)
  return #api.nvim_buf_get_extmarks(bufnr, usage_namespace, 0, -1, {}) > 0
end

function M.clear_highlights(bufnr)
  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_clear_namespace(bufnr, usage_namespace, 0, -1)
  end
  M.last_count[bufnr] = 0
end

function M.buf_au_group_name(bufnr)
  if not bufnr or bufnr == 0 then
    bufnr = vim.fn.bufnr('%')
  end
  return string.format('Highlight_usages_in_window_%d', bufnr)
end

function M.is_attached(bufnr)
  local au_group_name = M.buf_au_group_name(bufnr)
  local status, aus = pcall(api.nvim_get_autocmds, { group = au_group_name })
  if status and #(aus or {}) > 0 then
    return true
  else
    return false
  end
end

function M.attach(bufnr)
  if M.is_attached(bufnr) then
    return
  end
  local au = api.nvim_create_augroup(M.buf_au_group_name(bufnr), { clear = true })
  local highlighter_args = {
    group = au,
    buffer = bufnr,
    callback = function()
      if DEBOUNCE_TIMEOUT == 0 then
        M.highlight_usages(bufnr)
      else
        if M.debounce_timer then
          M.debounce_timer:stop()
          M.debounce_timer:close()
        end
        M.debounce_timer = uv.new_timer()
        M.debounce_timer:start(DEBOUNCE_TIMEOUT, 0, function()
          vim.schedule(function()
            M.highlight_usages(bufnr)
          end)
        end)
      end
    end,
  }
  api.nvim_create_autocmd({ 'CursorMoved', 'WinScrolled' }, highlighter_args)
  if INSERT_MODE then
    api.nvim_create_autocmd({ 'CursorMovedI' }, highlighter_args)
  else
    api.nvim_create_autocmd({ 'InsertEnter' }, {
      group = au,
      buffer = bufnr,
      callback = function()
        M.clear_highlights(bufnr)
        M.last_cache[bufnr] = nil
      end,
    })
  end
  api.nvim_create_autocmd({ 'BufUnload' }, {
    group = au,
    buffer = bufnr,
    callback = function()
      M.clear_highlights(bufnr)
      M.last_cache[bufnr] = nil
      M.detach(bufnr)
    end,
  })
  highlighter_args.callback()
end

function M.detach(bufnr)
  M.clear_highlights(bufnr)
  M.last_cache[bufnr] = nil
  if M.debounce_timer then
    M.debounce_timer:stop()
    M.debounce_timer:close()
    M.debounce_timer = nil
  end
  api.nvim_del_augroup_by_name(M.buf_au_group_name(bufnr))
end

local function setup_highlight_group()
  api.nvim_set_hl(0, HLGROUP, {
    bold = true, -- keep existing colors; just embolden matches
    underline = true,
    default = true,
  })
end

function M.setup()
  setup_highlight_group()
  api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = setup_highlight_group,
  })

  local au = api.nvim_create_augroup('Highlight_usages_in_window', { clear = true })
  api.nvim_create_autocmd('BufRead', {
    group = au,
    pattern = '*.*',
    callback = function(data)
      M.attach(data.buf)
    end,
  })

  --- add togglecommands
  api.nvim_create_user_command('LocalHighlightOff', function()
    M.detach(vim.fn.bufnr('%'))
  end, { desc = 'Turn local-highligh.nvim off' })
  api.nvim_create_user_command('LocalHighlightOn', function()
    M.attach(vim.fn.bufnr('%'))
  end, { desc = 'Turn local-highligh.nvim on' })
  api.nvim_create_user_command('LocalHighlightToggle', function()
    local bufnr = vim.fn.bufnr('%')
    if M.is_attached(bufnr) then
      M.detach(bufnr)
    else
      M.attach(bufnr)
    end
  end, { desc = 'Toggle local-highligh.nvim' })

  api.nvim_create_user_command('LocalHighlightStats', function()
    api.nvim_echo({ { M.stats() } }, false, {})
  end, { force = true })
end

return M
