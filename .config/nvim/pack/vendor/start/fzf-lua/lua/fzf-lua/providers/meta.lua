local core = require "fzf-lua.core"

local M = {}

---@param opts fzf-lua.config.Builtin|{}?
---@return thread?, string?, table?
M.metatable = function(opts)
  if not opts then return end

  -- fall back to string metamethods when a table isn't provided
  if not opts.metatable then opts.metatable = getmetatable("").__index end

  local methods = {}
  for k, _ in pairs(opts.metatable) do
    if not opts.metatable_exclude or opts.metatable_exclude[k] == nil then
      table.insert(methods, k)
    end
  end

  table.sort(methods, function(a, b) return a < b end)

  return core.fzf_exec(methods, opts)
end

return M
