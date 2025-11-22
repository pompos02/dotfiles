-- Minimal, local-only subset of mini.surround providing add/delete/replace.
-- Inspired by echasnovski/mini.surround but trimmed to the requested actions.
local M = {}
local H = {}

-- Default configuration
M.config = {
  custom_surroundings = nil,
  mappings = {
    add = 'sa',
    delete = 'sd',
    replace = 'sr',
  },
  n_lines = 20,
  respect_selection_type = false,
  search_method = 'cover',
  silent = false,
}

H.default_config = vim.deepcopy(M.config)

-- Cache used for dot-repeat and passing operator context
H.cache = {}

-- Namespaces
H.ns_id = {
  input = vim.api.nvim_create_namespace('MiniSurroundBasicInput'),
}

-- Builtin surroundings (copied from mini.surround)
H.builtin_surroundings = {
  ['('] = { input = { '%b()', '^.%s*().-()%s*.$' }, output = { left = '( ', right = ' )' } },
  [')'] = { input = { '%b()', '^.().*().$' },       output = { left = '(',  right = ')' } },
  ['['] = { input = { '%b[]', '^.%s*().-()%s*.$' }, output = { left = '[ ', right = ' ]' } },
  [']'] = { input = { '%b[]', '^.().*().$' },       output = { left = '[',  right = ']' } },
  ['{'] = { input = { '%b{}', '^.%s*().-()%s*.$' }, output = { left = '{ ', right = ' }' } },
  ['}'] = { input = { '%b{}', '^.().*().$' },       output = { left = '{',  right = '}' } },
  ['<'] = { input = { '%b<>', '^.%s*().-()%s*.$' }, output = { left = '< ', right = ' >' } },
  ['>'] = { input = { '%b<>', '^.().*().$' },       output = { left = '<',  right = '>' } },
  ['?'] = {
    input = function()
      local left = M.user_input('Left surrounding')
      if left == nil or left == '' then return end
      local right = M.user_input('Right surrounding')
      if right == nil or right == '' then return end
      return { vim.pesc(left) .. '().-()' .. vim.pesc(right) }
    end,
    output = function()
      local left = M.user_input('Left surrounding')
      if left == nil then return end
      local right = M.user_input('Right surrounding')
      if right == nil then return end
      return { left = left, right = right }
    end,
  },
  ['b'] = { input = { { '%b()', '%b[]', '%b{}' }, '^.().*().$' }, output = { left = '(', right = ')' } },
  ['f'] = {
    input = { '%f[%w_%.][%w_%.]+%b()', '^.-%(().*()%)$' },
    output = function()
      local fun_name = M.user_input('Function name')
      if fun_name == nil then return nil end
      return { left = ('%s('):format(fun_name), right = ')' }
    end,
  },
  ['t'] = {
    input = { '<(%w-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' },
    output = function()
      local tag_full = M.user_input('Tag')
      if tag_full == nil then return nil end
      local tag_name = tag_full:match('^%S*')
      return { left = '<' .. tag_full .. '>', right = '</' .. tag_name .. '>' }
    end,
  },
  ['q'] = { input = { { "'.-'", '".-"', '`.-`' }, '^.().*().$' }, output = { left = '"', right = '"' } },
}

-- Setup ---------------------------------------------------------------------
M.setup = function(config)
  _G.MiniSurroundBasic = M
  config = H.setup_config(config)
  H.apply_config(config)
end

-- Core actions --------------------------------------------------------------
M.add = function(mode)
  if H.is_disabled() then return '<Esc>' end

  local marks = H.get_marks_pos(mode)
  local surr_info = (mode == 'visual') and H.get_surround_spec('output', false) or H.get_surround_spec('output', true)
  if surr_info == nil then return '<Esc>' end

  if not surr_info.did_count then
    local count = H.cache.count or vim.v.count1
    surr_info.left, surr_info.right = surr_info.left:rep(count), surr_info.right:rep(count)
    surr_info.did_count = true
  end

  local respect_selection_type = H.get_config().respect_selection_type
  if not respect_selection_type or marks.selection_type == 'charwise' then
    H.region_replace({ from = { line = marks.second.line, col = marks.second.col + 1 } }, surr_info.right)
    H.region_replace({ from = marks.first }, surr_info.left)
    H.set_cursor(marks.first.line, marks.first.col + surr_info.left:len())
    return
  end

  if marks.selection_type == 'linewise' then
    local from_line, to_line = marks.first.line, marks.second.line
    local init_indent = H.get_range_indent(from_line, to_line)
    H.shift_indent('>', from_line, to_line)
    H.set_cursor_nonblank(from_line)
    vim.fn.append(to_line, init_indent .. surr_info.right)
    vim.fn.append(from_line - 1, init_indent .. surr_info.left)
    return
  end

  if marks.selection_type == 'blockwise' then
    local from_col, to_col = marks.first.col, marks.second.col
    from_col, to_col = math.min(from_col, to_col), math.max(from_col, to_col)
    for i = marks.first.line, marks.second.line do
      H.region_replace({ from = { line = i, col = to_col + 1 } }, surr_info.right)
      H.region_replace({ from = { line = i, col = from_col } }, surr_info.left)
    end
    H.set_cursor(marks.first.line, from_col + surr_info.left:len())
  end
end

M.delete = function()
  local surr = H.find_surrounding(H.get_surround_spec('input', true))
  if surr == nil then return '<Esc>' end

  H.region_replace(surr.right, {})
  H.region_replace(surr.left, {})

  local from = surr.left.from
  H.set_cursor(from.line, from.col)

  if not H.get_config().respect_selection_type then return end

  local from_line, to_line = surr.left.from.line, surr.right.from.line
  local is_linewise_delete = from_line < to_line and H.is_line_blank(from_line) and H.is_line_blank(to_line)
  if is_linewise_delete then
    H.shift_indent('<', from_line, to_line)
    H.set_cursor_nonblank(from_line + 1)
    local buf_id = vim.api.nvim_get_current_buf()
    vim.fn.deletebufline(buf_id, to_line)
    vim.fn.deletebufline(buf_id, from_line)
  end
end

M.replace = function()
  local surr = H.find_surrounding(H.get_surround_spec('input', true))
  if surr == nil then return '<Esc>' end

  local new_surr_info = H.get_surround_spec('output', true)
  if new_surr_info == nil then return '<Esc>' end

  H.region_replace(surr.right, new_surr_info.right)
  H.region_replace(surr.left, new_surr_info.left)

  local from = surr.left.from
  H.set_cursor(from.line, from.col + new_surr_info.left:len())
end

-- Input helpers -------------------------------------------------------------
M.user_input = function(prompt, text)
  local on_key = vim.on_key or vim.register_keystroke_callback
  local was_cancelled = false
  on_key(function(key)
    if key == vim.api.nvim_replace_termcodes('<Esc>', true, true, true) then was_cancelled = true end
  end, H.ns_id.input)

  local opts = { prompt = '(surround) ' .. prompt .. ': ', default = text or '' }
  vim.cmd('echohl Question')
  local ok, res = pcall(vim.fn.input, opts)
  vim.cmd([[echohl None | echo '' | redraw]])
  on_key(nil, H.ns_id.input)

  if not ok or was_cancelled then return end
  return res
end

-- Configuration -------------------------------------------------------------
H.setup_config = function(config)
  config = vim.tbl_deep_extend('force', vim.deepcopy(H.default_config), config or {})
  H.check_type('custom_surroundings', config.custom_surroundings, 'table', true)
  H.check_type('mappings', config.mappings, 'table')
  H.check_type('n_lines', config.n_lines, 'number')
  H.check_type('respect_selection_type', config.respect_selection_type, 'boolean')
  H.validate_search_method(config.search_method)
  H.check_type('silent', config.silent, 'boolean')
  H.check_type('mappings.add', config.mappings.add, 'string')
  H.check_type('mappings.delete', config.mappings.delete, 'string')
  H.check_type('mappings.replace', config.mappings.replace, 'string')
  return config
end

H.apply_config = function(config)
  M.config = config
  local expr_map = function(lhs, rhs, desc) H.map('n', lhs, rhs, { expr = true, desc = desc }) end
  local map = function(lhs, rhs, desc) H.map('x', lhs, rhs, { desc = desc }) end

  local m = config.mappings
  expr_map(m.add, H.make_operator('add', nil, true), 'Add surrounding')
  expr_map(m.delete, H.make_operator('delete'), 'Delete surrounding')
  expr_map(m.replace, H.make_operator('replace'), 'Replace surrounding')
  map(m.add, [[:<C-u>lua MiniSurroundBasic.add('visual')<CR>]], 'Add surrounding to selection')
end

H.get_config = function(config)
  return vim.tbl_deep_extend('force', M.config, vim.b.minisurround_config or {}, config or {})
end

H.validate_search_method = function(x)
  local allowed_methods = vim.tbl_keys(H.span_compare_methods)
  if vim.tbl_contains(allowed_methods, x) then return end
  table.sort(allowed_methods)
  local allowed_methods_string = table.concat(vim.tbl_map(vim.inspect, allowed_methods), ', ')
  H.error('`search_method` should be one of ' .. allowed_methods_string)
end

-- Mapping helpers -----------------------------------------------------------
H.make_operator = function(task, search_method, ask_for_textobject)
  return function()
    if H.is_disabled() then return [[\<Esc>]] end
    H.cache = { count = vim.v.count1, search_method = search_method }
    vim.o.operatorfunc = 'v:lua.MiniSurroundBasic.' .. task
    return '<Cmd>redraw<CR>g@' .. (ask_for_textobject and '' or ' ')
  end
end

H.map = function(mode, lhs, rhs, opts)
  if lhs == '' then return end
  opts = vim.tbl_deep_extend('force', { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
  local no_global_s_mapping = not H.has_global_mapping(mode, 's')
  if no_global_s_mapping and lhs:find('^s.') ~= nil then vim.keymap.set(mode, 's', '<Nop>') end
end

H.has_global_mapping = function(mode, lhs)
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if map.lhs == lhs then return true end
  end
  return false
end

-- Surround resolution -------------------------------------------------------
H.get_surround_spec = function(sur_type, use_cache)
  local res
  if use_cache then
    res = H.cache[sur_type]
    if res ~= nil then return res end
  else
    H.cache = {}
  end

  local char = H.user_surround_id(sur_type)
  if char == nil then return nil end

  res = H.make_surrounding_table()[char][sur_type]
  if vim.is_callable(res) then res = res() end
  if not H.is_surrounding_info(res, sur_type) then return nil end
  if H.is_composed_pattern(res) then res = vim.tbl_map(H.wrap_callable_table, res) end
  res = setmetatable(res, { __index = { id = char } })
  if use_cache then H.cache[sur_type] = res end
  return res
end

H.make_surrounding_table = function()
  local surroundings = vim.deepcopy(H.builtin_surroundings)
  for char, spec in pairs(H.get_config().custom_surroundings or {}) do
    local cur_spec = surroundings[char] or {}
    local default = H.get_default_surrounding_info(char)
    cur_spec.input = spec.input or cur_spec.input or default.input
    cur_spec.output = spec.output or cur_spec.output or default.output
    surroundings[char] = cur_spec
  end
  return setmetatable(surroundings, {
    __index = function(_, key) return H.get_default_surrounding_info(key) end,
  })
end

H.get_default_surrounding_info = function(char)
  local char_esc = vim.pesc(char)
  return { input = { char_esc .. '().-()' .. char_esc }, output = { left = char, right = char } }
end

H.is_surrounding_info = function(x, sur_type)
  if sur_type == 'input' then
    return H.is_composed_pattern(x) or H.is_region_pair(x) or H.is_region_pair_array(x)
  elseif sur_type == 'output' then
    return (type(x) == 'table' and type(x.left) == 'string' and type(x.right) == 'string')
  end
end

H.is_region = function(x)
  if type(x) ~= 'table' then return false end
  local from_is_valid = type(x.from) == 'table' and type(x.from.line) == 'number' and type(x.from.col) == 'number'
  local to_is_valid = true
  if x.to ~= nil then
    to_is_valid = type(x.to) == 'table' and type(x.to.line) == 'number' and type(x.to.col) == 'number'
  end
  return from_is_valid and to_is_valid
end

H.is_region_pair = function(x)
  if type(x) ~= 'table' then return false end
  return H.is_region(x.left) and H.is_region(x.right)
end

H.is_region_pair_array = function(x)
  if not H.islist(x) then return false end
  for _, v in ipairs(x) do
    if not H.is_region_pair(v) then return false end
  end
  return true
end

H.is_composed_pattern = function(x)
  if not (H.islist(x) and #x > 0) then return false end
  for _, val in ipairs(x) do
    local val_type = type(val)
    if not (val_type == 'table' or val_type == 'string' or vim.is_callable(val)) then return false end
  end
  return true
end

-- Surround search -----------------------------------------------------------
H.find_surrounding = function(surr_spec, opts)
  if surr_spec == nil then return end
  if H.is_region_pair(surr_spec) then return surr_spec end

  opts = vim.tbl_deep_extend('force', H.get_default_opts(), opts or {})
  H.validate_search_method(opts.search_method)

  local region_pair = H.find_surrounding_region_pair(surr_spec, opts)
  if region_pair == nil then
    local msg = ([[No surrounding %s found within %d line%s and `search_method = '%s'`.]]):format(
      vim.inspect((opts.n_times > 1 and opts.n_times or '') .. surr_spec.id),
      opts.n_lines,
      opts.n_lines > 1 and 's' or '',
      opts.search_method
    )
    H.message(msg)
  end

  return region_pair
end

H.find_surrounding_region_pair = function(surr_spec, opts)
  local reference_region, n_times, n_lines = opts.reference_region, opts.n_times, opts.n_lines
  if n_times == 0 then return end

  local neigh = H.get_neighborhood(reference_region, 0)
  local reference_span = neigh.region_to_span(reference_region)

  local find_next = function(cur_reference_span)
    local res = H.find_best_match(neigh, surr_spec, cur_reference_span, opts)
    if res.span == nil then
      if n_lines == 0 or neigh.n_neighbors > 0 then return {} end
      local cur_reference_region = neigh.span_to_region(cur_reference_span)
      neigh = H.get_neighborhood(reference_region, n_lines)
      reference_span = neigh.region_to_span(reference_region)
      cur_reference_span = neigh.region_to_span(cur_reference_region)
      res = H.find_best_match(neigh, surr_spec, cur_reference_span, opts)
    end
    return res
  end

  local find_res = { span = reference_span }
  for _ = 1, n_times do
    find_res = find_next(find_res.span)
    if find_res.span == nil then return end
  end

  local extract = function(span, extract_pattern)
    if type(extract_pattern) == 'table' then return extract_pattern end
    local s = neigh['1d']:sub(span.from, span.to - 1)
    local local_surr_spans = H.extract_surr_spans(s, extract_pattern)
    local off = span.from - 1
    local left, right = local_surr_spans.left, local_surr_spans.right
    return {
      left = { from = left.from + off, to = left.to + off },
      right = { from = right.from + off, to = right.to + off },
    }
  end

  local final_spans = extract(find_res.span, find_res.extract_pattern)
  local outer_span = { from = final_spans.left.from, to = final_spans.right.to }

  if H.is_span_covering(reference_span, outer_span) then
    find_res = find_next(find_res.span)
    if find_res.span == nil then return end
    final_spans = extract(find_res.span, find_res.extract_pattern)
    outer_span = { from = final_spans.left.from, to = final_spans.right.to }
    if H.is_span_covering(reference_span, outer_span) then return end
  end

  return { left = neigh.span_to_region(final_spans.left), right = neigh.span_to_region(final_spans.right) }
end

H.find_best_match = function(neighborhood, surr_spec, reference_span, opts)
  local best_span, best_nested_pattern, current_nested_pattern
  local f = function(span)
    if H.is_better_span(span, best_span, reference_span, opts) then
      best_span = span
      best_nested_pattern = current_nested_pattern
    end
  end

  if H.is_region_pair_array(surr_spec) then
    for _, region_pair in ipairs(surr_spec) do
      local outer_region = { from = region_pair.left.from, to = region_pair.right.to or region_pair.right.from }
      if neighborhood.is_region_inside(outer_region) then
        current_nested_pattern = { {
          left = neighborhood.region_to_span(region_pair.left),
          right = neighborhood.region_to_span(region_pair.right),
        } }
        f(neighborhood.region_to_span(outer_region))
      end
    end
  else
    for _, nested_pattern in ipairs(H.cartesian_product(surr_spec)) do
      current_nested_pattern = nested_pattern
      H.iterate_matched_spans(neighborhood['1d'], nested_pattern, f)
    end
  end

  local extract_pattern
  if best_nested_pattern ~= nil then extract_pattern = best_nested_pattern[#best_nested_pattern] end
  return { span = best_span, extract_pattern = extract_pattern }
end

H.iterate_matched_spans = function(line, nested_pattern, f)
  local max_level = #nested_pattern
  local visited = {}
  local process
  process = function(level, level_line, level_offset)
    local pattern = nested_pattern[level]
    local next_span = function(s, init) return H.string_find(s, pattern, init) end
    if vim.is_callable(pattern) then next_span = pattern end

    local is_same_balanced = type(pattern) == 'string' and pattern:match('^%%b(.)%1$') ~= nil
    local init = 1
    while init <= level_line:len() do
      local from, to = next_span(level_line, init)
      if from == nil then break end

      if level == max_level then
        local found_match = H.new_span(from + level_offset, to + level_offset)
        local found_match_id = string.format('%s_%s', found_match.from, found_match.to)
        if not visited[found_match_id] then
          f(found_match)
          visited[found_match_id] = true
        end
      else
        local next_level_line = level_line:sub(from, to)
        local next_level_offset = level_offset + from - 1
        process(level + 1, next_level_line, next_level_offset)
      end

      init = (is_same_balanced and to or from) + 1
    end
  end
  process(1, line, 0)
end

H.new_span = function(from, to) return { from = from, to = to == nil and from or (to + 1) } end

H.is_better_span = function(candidate, current, reference, opts)
  if H.is_span_covering(reference, candidate) or H.is_span_equal(candidate, reference) then return false end
  return H.span_compare_methods[opts.search_method](candidate, current, reference)
end

H.span_compare_methods = {
  cover = function(candidate, current, reference)
    local res = H.is_better_covering_span(candidate, current, reference)
    if res ~= nil then return res end
    return false
  end,

  cover_or_next = function(candidate, current, reference)
    local res = H.is_better_covering_span(candidate, current, reference)
    if res ~= nil then return res end
    if not H.is_span_on_left(reference, candidate) then return false end
    if current == nil then return true end
    local dist = H.span_distance.next
    return dist(candidate, reference) < dist(current, reference)
  end,

  cover_or_prev = function(candidate, current, reference)
    local res = H.is_better_covering_span(candidate, current, reference)
    if res ~= nil then return res end
    if not H.is_span_on_left(candidate, reference) then return false end
    if current == nil then return true end
    local dist = H.span_distance.prev
    return dist(candidate, reference) < dist(current, reference)
  end,

  cover_or_nearest = function(candidate, current, reference)
    local res = H.is_better_covering_span(candidate, current, reference)
    if res ~= nil then return res end
    if current == nil then return true end
    local dist = H.span_distance.near
    return dist(candidate, reference) < dist(current, reference)
  end,

  next = function(candidate, current, reference)
    if H.is_span_covering(candidate, reference) then return false end
    if not H.is_span_on_left(reference, candidate) then return false end
    if current == nil then return true end
    local dist = H.span_distance.next
    return dist(candidate, reference) < dist(current, reference)
  end,

  prev = function(candidate, current, reference)
    if H.is_span_covering(candidate, reference) then return false end
    if not H.is_span_on_left(candidate, reference) then return false end
    if current == nil then return true end
    local dist = H.span_distance.prev
    return dist(candidate, reference) < dist(current, reference)
  end,

  nearest = function(candidate, current, reference)
    if H.is_span_covering(candidate, reference) then return false end
    if current == nil then return true end
    local dist = H.span_distance.near
    return dist(candidate, reference) < dist(current, reference)
  end,
}

H.span_distance = {
  next = function(span_1, span_2) return math.abs(span_1.from - span_2.from) end,
  prev = function(span_1, span_2) return math.abs(span_1.to - span_2.to) end,
  near = function(span_1, span_2) return math.min(math.abs(span_1.from - span_2.from), math.abs(span_1.to - span_2.to)) end,
}

H.is_better_covering_span = function(candidate, current, reference)
  local candidate_is_covering = H.is_span_covering(candidate, reference)
  local current_is_covering = H.is_span_covering(current, reference)

  if candidate_is_covering and current_is_covering then
    return (candidate.to - candidate.from) < (current.to - current.from)
  end
  if candidate_is_covering and not current_is_covering then return true end
  if not candidate_is_covering and current_is_covering then return false end
  return nil
end

H.is_span_covering = function(span, span_to_cover)
  if span == nil or span_to_cover == nil then return false end
  if span.from == span.to then
    return (span.from == span_to_cover.from) and (span_to_cover.to == span.to)
  end
  if span_to_cover.from == span_to_cover.to then
    return (span.from <= span_to_cover.from) and (span_to_cover.to < span.to)
  end
  return (span.from <= span_to_cover.from) and (span_to_cover.to <= span.to)
end

H.is_span_equal = function(span_1, span_2)
  if span_1 == nil or span_2 == nil then return false end
  return (span_1.from == span_2.from) and (span_1.to == span_2.to)
end

H.is_span_on_left = function(span_1, span_2)
  if span_1 == nil or span_2 == nil then return false end
  return (span_1.from <= span_2.from) and (span_1.to <= span_2.to)
end

H.extract_surr_spans = function(s, extract_pattern)
  local positions = { s:match(extract_pattern) }
  local is_all_numbers = true
  for _, pos in ipairs(positions) do
    if type(pos) ~= 'number' then is_all_numbers = false end
  end
  local is_valid_positions = is_all_numbers and (#positions == 2 or #positions == 4)
  if not is_valid_positions then
    local msg = 'Could not extract proper positions (two or four empty captures) from '
      .. string.format([[string '%s' with extraction pattern '%s'.]], s, extract_pattern)
    H.error(msg)
  end
  if #positions == 2 then
    return { left = H.new_span(1, positions[1] - 1), right = H.new_span(positions[2], s:len()) }
  end
  return { left = H.new_span(positions[1], positions[2] - 1), right = H.new_span(positions[3], positions[4] - 1) }
end

H.get_neighborhood = function(reference_region, n_neighbors)
  local from_line, to_line = reference_region.from.line, (reference_region.to or reference_region.from).line
  local line_start = math.max(1, from_line - n_neighbors)
  local line_end = math.min(vim.api.nvim_buf_line_count(0), to_line + n_neighbors)
  local neigh2d = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
  for k, v in pairs(neigh2d) do
    neigh2d[k] = v .. '\n'
  end
  local neigh1d = table.concat(neigh2d, '')

  local pos_to_offset = function(pos)
    if pos == nil then return nil end
    local line_num = line_start
    local offset = 0
    while line_num < pos.line do
      offset = offset + neigh2d[line_num - line_start + 1]:len()
      line_num = line_num + 1
    end
    return offset + pos.col
  end

  local offset_to_pos = function(offset)
    if offset == nil then return nil end
    local line_num = 1
    local line_offset = 0
    while line_num <= #neigh2d and line_offset + neigh2d[line_num]:len() < offset do
      line_offset = line_offset + neigh2d[line_num]:len()
      line_num = line_num + 1
    end
    return { line = line_start + line_num - 1, col = offset - line_offset }
  end

  local region_to_span = function(region)
    if region == nil then return nil end
    local is_empty = region.to == nil
    local to = region.to or region.from
    return { from = pos_to_offset(region.from), to = pos_to_offset(to) + (is_empty and 0 or 1) }
  end

  local span_to_region = function(span)
    if span == nil then return nil end
    local res = { from = offset_to_pos(span.from) }
    if span.from < span.to then res.to = offset_to_pos(span.to - 1) end
    return res
  end

  local is_region_inside = function(region)
    local res = line_start <= region.from.line
    if region.to ~= nil then res = res and (region.to.line <= line_end) end
    return res
  end

  return {
    n_neighbors = n_neighbors,
    region = reference_region,
    ['1d'] = neigh1d,
    ['2d'] = neigh2d,
    pos_to_offset = pos_to_offset,
    offset_to_pos = offset_to_pos,
    region_to_span = region_to_span,
    span_to_region = span_to_region,
    is_region_inside = is_region_inside,
  }
end

H.get_default_opts = function()
  local config = H.get_config()
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  return {
    n_lines = config.n_lines,
    n_times = H.cache.count or vim.v.count1,
    reference_region = { from = { line = cur_pos[1], col = cur_pos[2] + 1 } },
    search_method = H.cache.search_method or config.search_method,
  }
end

-- Marks/selection -----------------------------------------------------------
H.get_marks_pos = function(mode)
  local mark1, mark2
  if mode == 'visual' then
    mark1, mark2 = '<', '>'
  else
    mark1, mark2 = '[', ']'
  end

  local pos1 = vim.api.nvim_buf_get_mark(0, mark1)
  local pos2 = vim.api.nvim_buf_get_mark(0, mark2)
  local selection_type = H.get_selection_type(mode)

  if selection_type == 'linewise' then
    local _, line1_indent = vim.fn.getline(pos1[1]):find('^%s*')
    pos1[2] = line1_indent
    pos2[2] = vim.fn.getline(pos2[1]):find('%s*$') - 2
  end

  pos1[2], pos2[2] = pos1[2] + 1, pos2[2] + 1

  if mode == 'visual' and vim.o.selection == 'exclusive' then
    pos2[2] = pos2[2] - 1
  else
    local line2 = vim.fn.getline(pos2[1])
    local utf_index = vim.str_utfindex(line2, math.min(#line2, pos2[2]))
    pos2[2] = vim.str_byteindex(line2, utf_index)
  end

  return {
    first = { line = pos1[1], col = pos1[2] },
    second = { line = pos2[1], col = pos2[2] },
    selection_type = selection_type,
  }
end

H.get_selection_type = function(mode)
  if (mode == 'char') or (mode == 'visual' and vim.fn.visualmode() == 'v') then return 'charwise' end
  if (mode == 'line') or (mode == 'visual' and vim.fn.visualmode() == 'V') then return 'linewise' end
  if (mode == 'block') or (mode == 'visual' and vim.fn.visualmode() == '\22') then return 'blockwise' end
end

-- Region/text helpers -------------------------------------------------------
H.region_replace = function(region, text)
  local start_row, start_col = region.from.line - 1, region.from.col - 1
  local end_row, end_col
  if H.region_is_empty(region) then
    end_row, end_col = start_row, start_col
  else
    end_row, end_col = region.to.line - 1, region.to.col
    if end_row < vim.api.nvim_buf_line_count(0) and H.get_line_cols(end_row + 1) < end_col then
      end_row, end_col = end_row + 1, 0
    end
  end

  if type(text) == 'string' then text = { text } end
  if #text > 0 then text = vim.split(table.concat(text, '\n'), '\n') end
  pcall(vim.api.nvim_buf_set_text, 0, start_row, start_col, end_row, end_col, text)
end

H.region_is_empty = function(region) return region.to == nil end

H.get_range_indent = function(from_line, to_line)
  local n_indent, indent = math.huge, nil
  local lines = vim.api.nvim_buf_get_lines(0, from_line - 1, to_line, true)
  local n_indent_cur, indent_cur
  for _, l in ipairs(lines) do
    _, n_indent_cur, indent_cur = l:find('^(%s*)')
    if n_indent_cur < n_indent and n_indent_cur < l:len() then
      n_indent, indent = n_indent_cur, indent_cur
    end
  end
  return indent or ''
end

H.shift_indent = function(command, from_line, to_line)
  if to_line < from_line then return end
  vim.cmd('silent ' .. from_line .. ',' .. to_line .. command)
end

H.is_line_blank = function(line_num) return vim.fn.nextnonblank(line_num) ~= line_num end

H.set_cursor = function(line, col) vim.api.nvim_win_set_cursor(0, { line, col - 1 }) end

H.set_cursor_nonblank = function(line)
  H.set_cursor(line, 1)
  vim.cmd('normal! ^')
end

H.get_line_cols = function(line_num) return vim.fn.getline(line_num):len() end

-- User input helpers --------------------------------------------------------
H.user_surround_id = function(sur_type)
  local needs_help_msg = true
  vim.defer_fn(function()
    if not needs_help_msg then return end
    local msg = string.format('Enter %s surrounding identifier (single character) ', sur_type)
    H.echo(msg)
    H.cache.msg_shown = true
  end, 1000)
  local ok, char = pcall(vim.fn.getcharstr)
  needs_help_msg = false
  H.unecho()
  if not ok or char == '\27' then return nil end
  return char
end

-- Utils ---------------------------------------------------------------------
H.is_disabled = function() return vim.g.minisurround_disable == true or vim.b.minisurround_disable == true end

H.error = function(msg) error('(mini.surround.basic) ' .. msg, 0) end

H.check_type = function(name, val, ref, allow_nil)
  if type(val) == ref or (ref == 'callable' and vim.is_callable(val)) or (allow_nil and val == nil) then return end
  H.error(string.format('`%s` should be %s, not %s', name, ref, type(val)))
end

H.echo = function(msg, is_important)
  if H.get_config().silent then return end
  msg = type(msg) == 'string' and { { msg } } or msg
  table.insert(msg, 1, { '(surround) ', 'WarningMsg' })
  local max_width = vim.o.columns * math.max(vim.o.cmdheight - 1, 0) + vim.v.echospace
  local chunks, tot_width = {}, 0
  for _, ch in ipairs(msg) do
    local new_ch = { vim.fn.strcharpart(ch[1], 0, max_width - tot_width), ch[2] }
    table.insert(chunks, new_ch)
    tot_width = tot_width + vim.fn.strdisplaywidth(new_ch[1])
    if tot_width >= max_width then break end
  end
  vim.cmd([[echo '' | redraw]])
  vim.api.nvim_echo(chunks, is_important, {})
end

H.unecho = function()
  if H.cache.msg_shown then vim.cmd([[echo '' | redraw]]) end
end

H.message = function(msg) H.echo(msg, true) end

H.string_find = function(s, pattern, init)
  init = init or 1
  if pattern:sub(1, 1) == '^' then
    if init > 1 then return nil end
    return string.find(s, pattern)
  end
  local check_left, _, prev = string.find(pattern, '(.)%.%-')
  local is_pattern_special = check_left ~= nil and prev ~= '%'
  if not is_pattern_special then return string.find(s, pattern, init) end
  local from, to = string.find(s, pattern, init)
  if from == nil then return end
  local cur_from, cur_to = from, to
  while cur_to == to do
    from, to = cur_from, cur_to
    cur_from, cur_to = string.find(s, pattern, cur_from + 1)
  end
  return from, to
end

H.cartesian_product = function(arr)
  if not (type(arr) == 'table' and #arr > 0) then return {} end
  arr = vim.tbl_map(function(x) return H.islist(x) and x or { x } end, arr)
  local res, cur_item = {}, {}
  local process
  process = function(level)
    for i = 1, #arr[level] do
      table.insert(cur_item, arr[level][i])
      if level == #arr then
        table.insert(res, H.tbl_flatten(cur_item))
      else
        process(level + 1)
      end
      table.remove(cur_item, #cur_item)
    end
  end
  process(1)
  return res
end

H.wrap_callable_table = function(x)
  if vim.is_callable(x) and type(x) == 'table' then
    return function(...) return x(...) end
  end
  return x
end

H.islist = vim.fn.has('nvim-0.10') == 1 and vim.islist or vim.tbl_islist
H.tbl_flatten = vim.fn.has('nvim-0.10') == 1 and function(x) return vim.iter(x):flatten(math.huge):totable() end
  or vim.tbl_flatten

return M
