local utils = require "fzf-lua.utils"
local path = require "fzf-lua.path"

local M = {}

-- Basic expectations wrapper
M.expect = function(actions, opts)
  opts = opts or {}
  opts.actions = opts.actions or actions
  return opts
end

-- Normalize selected entries to a simple table
M.normalize_selected = function(selected)
  if type(selected) ~= "table" then return {} end
  return selected
end

-- Core execute
M.act = function(selected, opts)
  selected = M.normalize_selected(selected)
  if not opts or not opts.actions then return end
  local fn = opts.actions.enter or opts.actions.default
  if type(fn) == "function" then
    return fn(selected, opts)
  elseif type(fn) == "table" and type(fn.fn) == "function" then
    return fn.fn(selected, opts)
  end
end

-- File actions
M.file_edit = function(selected, opts)
  local entry = path.entry_to_file(selected[1], opts)
  if entry and entry.path then vim.cmd("edit " .. vim.fn.fnameescape(entry.path)) end
end

M.file_split = function(selected, opts)
  local entry = path.entry_to_file(selected[1], opts)
  if entry and entry.path then vim.cmd("split " .. vim.fn.fnameescape(entry.path)) end
end

M.file_vsplit = function(selected, opts)
  local entry = path.entry_to_file(selected[1], opts)
  if entry and entry.path then vim.cmd("vsplit " .. vim.fn.fnameescape(entry.path)) end
end

M.file_tabedit = function(selected, opts)
  local entry = path.entry_to_file(selected[1], opts)
  if entry and entry.path then vim.cmd("tabedit " .. vim.fn.fnameescape(entry.path)) end
end

M.file_sel_to_qf = function(selected, opts)
  local entries = {}
  for _, s in ipairs(selected) do
    local e = path.entry_to_file(s, opts)
    if e and e.path then table.insert(entries, { filename = e.path }) end
  end
  vim.fn.setqflist({}, " ", { title = "FzfLua", items = entries })
end

M.file_sel_to_ll = function(selected, opts)
  local entries = {}
  for _, s in ipairs(selected) do
    local e = path.entry_to_file(s, opts)
    if e and e.path then table.insert(entries, { filename = e.path }) end
  end
  vim.fn.setloclist(0, {}, " ", { title = "FzfLua", items = entries })
end

M.file_edit_or_qf = function(selected, opts)
  if #selected == 1 then
    return M.file_edit(selected, opts)
  else
    return M.file_sel_to_qf(selected, opts)
  end
end

-- Toggles for grep/files
M.toggle_ignore = function(_, opts)
  opts = opts or {}
  opts.no_ignore = not opts.no_ignore
  return opts.__ACT_TO and opts.__ACT_TO(opts) or opts
end

M.toggle_hidden = function(_, opts)
  opts = opts or {}
  opts.hidden = not opts.hidden
  return opts.__ACT_TO and opts.__ACT_TO(opts) or opts
end

M.toggle_follow = function(_, opts)
  opts = opts or {}
  opts.follow = not opts.follow
  return opts.__ACT_TO and opts.__ACT_TO(opts) or opts
end

-- Help actions
local function helptags(s, opts)
  return vim.tbl_map(function(x)
    local entry = path.entry_to_file(x, opts)
    if entry and entry.path and package.loaded.lazy then
      local lazyConfig = require("lazy.core.config")
      local _, plugin = path.normalize(entry.path):match("(/([^/]+)/doc/)")
      if plugin and lazyConfig.plugins[plugin] then
        require("lazy").load({ plugins = { plugin } })
      end
    end
    return x:match("[^%s]+")
  end, s)
end

M.help = function(selected, opts)
  if not selected[1] then return end
  vim.cmd("help " .. helptags(selected, opts)[1])
end

M.help_curwin = function(selected, opts)
  if not selected[1] then return end
  vim.cmd("help " .. helptags(selected, opts)[1])
end

M.help_vert = function(selected, opts)
  if not selected[1] then return end
  vim.cmd("vert help " .. helptags(selected, opts)[1])
end

M.help_tab = function(selected, opts)
  if not selected[1] then return end
  utils.with({ go = { splitkeep = "cursor" } }, function()
    vim.cmd("tabnew | setlocal bufhidden=wipe | help " .. helptags(selected, opts)[1] .. " | only")
  end)
end

-- Keymap actions
M.keymap_apply = function(selected)
  if not selected[1] then return end
  local m, lhs = selected[1]:match("%[(%w+):([^:]+):")
  if m and lhs then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, false, true), m == "c" and "c" or "n", true)
  end
end

local function keymap_open(selected, cmd)
  if not selected[1] then return end
  local entry = selected[1]:match("%[([^%]]+)%]%s+%[([^%]]+)%]%s+(.*)")
  if entry then
    local _, _, rhs = entry:match("([^%s]+)%s+([^%s]+)%s+(.*)")
    if rhs then vim.cmd(string.format("%s %s", cmd, rhs)) end
  end
end

M.keymap_split = function(selected) keymap_open(selected, "split") end
M.keymap_vsplit = function(selected) keymap_open(selected, "vsplit") end
M.keymap_tabedit = function(selected) keymap_open(selected, "tabedit") end

-- Profiles apply helper
M.apply_profile = function(selected, opts)
  if not selected[1] then return end
  local fname = selected[1]:match("^([^:]+)")
  local ok = require("fzf-lua.utils").load_profile_fname(fname, fname:match("([^/]+)%.lua$"), opts and opts.silent)
  if ok then require("fzf-lua").setup({ fname }) end
end

-- Toggle between grep/live_grep targets (noop stub for minimal build)
M.grep_lgrep = function(_, opts)
  if opts and opts.__ACT_TO then return opts.__ACT_TO(opts) end
end

-- Minimal stubs for actions referenced elsewhere
M.dummy_abort = function() end
M.file_switch = function(selected, opts) return M.file_edit(selected, opts) end
M.file_switch_or_edit = M.file_edit_or_qf
M.buf_del = function() end
M.run_builtin = function() end
M.undo = function() end
M.ex_run = function() end
M.ex_run_cr = function() end

return M
