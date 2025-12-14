local core = require "fzf-lua.core"
local config = require "fzf-lua.config"
local utils = require "fzf-lua.utils"

local M = {}

---@param opts fzf-lua.config.Keymaps|{}?
---@return thread?, string?, table?
M.keymaps = function(opts)
  ---@type fzf-lua.config.Keymaps
  opts = config.normalize_opts(opts, "keymaps")
  if not opts then return end

  local key_modes = opts.modes or { "n", "i", "c", "v", "t" }
  local modes = { n = "blue", i = "red", c = "yellow", v = "magenta", t = "green" }
  local keymaps = {}
  local separator = "│"
  local fields = { "mode", "lhs", "desc", "rhs" }
  local field_fmt = { mode = "%s", lhs = "%-14s", desc = "%-33s", rhs = "%s" }

  if opts.show_desc == false then field_fmt.desc = nil end
  if opts.show_details == false then field_fmt.rhs = nil end

  local format = function(info)
    info.desc = field_fmt.rhs and string.sub(info.desc or "", 1, 33) or info.desc
    local ret
    for _, f in ipairs(fields) do
      if field_fmt[f] then
        ret = string.format("%s%s" .. field_fmt[f], ret or "",
          ret and string.format(" %s ", separator) or "", info[f] or "")
      end
    end
    return ret
  end

  local function add_keymap(keymap)
    if type(keymap.rhs) == "string" and #keymap.rhs == 0 then
      return
    end

    if type(keymap.lhs) == "string" and type(opts.ignore_patterns) == "table" then
      for _, p in ipairs(opts.ignore_patterns) do
        local pattern, lhs = p:lower(), vim.trim(keymap.lhs:lower())
        if lhs:match(pattern) then
          return
        end
      end
    end

    keymap.str = format({
      mode = utils.ansi_codes[modes[keymap.mode] or "blue"](keymap.mode),
      lhs  = keymap.lhs:gsub("%s", "<Space>"),
      desc = keymap.desc and string.gsub(keymap.desc, "\n%s+", "\r"),
      rhs  = keymap.rhs or string.format("%s", keymap.callback)
    })

    local k = string.format("[%s:%s:%s]", keymap.buffer, keymap.mode, keymap.lhs)
    keymaps[k] = keymap
  end

  for _, mode in pairs(key_modes) do
    for _, keymap in pairs(vim.api.nvim_get_keymap(mode)) do
      add_keymap(keymap)
    end
    for _, keymap in pairs(vim.api.nvim_buf_get_keymap(0, mode)) do
      add_keymap(keymap)
    end
  end

  local entries = {}
  for _, v in pairs(keymaps) do
    table.insert(entries, v.str)
  end

  opts.fzf_opts["--header-lines"] = "1"
  table.sort(entries)

  local header_str = format({ mode = "m", lhs = "keymap", desc = "description", rhs = "detail" })
  table.insert(entries, 1, header_str)

  return core.fzf_exec(entries, opts)
end

return M
