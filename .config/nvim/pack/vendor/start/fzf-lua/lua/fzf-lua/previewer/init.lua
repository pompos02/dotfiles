local Previewer = {}

Previewer.fzf = {}
Previewer.fzf.cmd = function() return require "fzf-lua.previewer.fzf".cmd end
Previewer.fzf.bat = function() return require "fzf-lua.previewer.fzf".bat end
Previewer.fzf.head = function() return require "fzf-lua.previewer.fzf".head end
Previewer.fzf.cmd_async = function() return require "fzf-lua.previewer.fzf".cmd_async end
Previewer.fzf.bat_async = function() return require "fzf-lua.previewer.fzf".bat_async end
Previewer.fzf.git_diff = function() return require "fzf-lua.previewer.fzf".git_diff end
Previewer.fzf.help_tags = function() return require "fzf-lua.previewer.fzf".help_tags end
Previewer.fzf.nvim_server = function() return require "fzf-lua.previewer.fzf".nvim_server end

Previewer.builtin = {}
Previewer.builtin.buffer_or_file = function()
  return require "fzf-lua.previewer.builtin".buffer_or_file
end
Previewer.builtin.help_tags = function() return require "fzf-lua.previewer.builtin".help_tags end
Previewer.builtin.marks = function() return require "fzf-lua.previewer.builtin".marks end
Previewer.builtin.jumps = function() return require "fzf-lua.previewer.builtin".jumps end
Previewer.builtin.keymaps = function() return require "fzf-lua.previewer.builtin".keymaps end


---@class fzf-lua.config.Previewer
---@field new? fun(opts: fzf-lua.config.Previewer, opt: fzf-lua.config.Previewer, o: fzf-lua.config.Resolved)
---@field _new? function(opt: fzf-lua.config.Previewer, o: fzf-lua.config.Resolved)
---@field _ctor? function(opt: fzf-lua.config.Previewer, o: fzf-lua.config.Resolved)
---@field cmd? string
---@field args? string
---@field preview_offset? string
---@field theme? string
---@field pager? string|function
---builtin
---@field title_fnamemodify? function

---Instantiate previewer from spec
---@param spec? fzf-lua.config.Previewer|string
---@param opts table
---@return fzf-lua.previewer.Fzf|fzf-lua.previewer.Builtin?
Previewer.new = function(spec, opts)
  if not spec then return end
  local previewer, preview_opts = nil, nil
  if type(spec) == "string" then
    preview_opts = FzfLua.config.globals.previewers[spec]
    if not preview_opts then
      FzfLua.utils.warn(("invalid previewer '%s'"):format(spec))
    end
  elseif type(spec) == "table" then
    preview_opts = spec
  end
  -- Backward compat: can instantiate with `_ctor|new|_new`
  if preview_opts and type(preview_opts.new) == "function" then
    previewer = preview_opts:new(preview_opts, opts)
  elseif preview_opts and type(preview_opts._new) == "function" then
    previewer = preview_opts._new()(preview_opts, opts)
  elseif preview_opts and type(preview_opts._ctor) == "function" then
    previewer = preview_opts._ctor()(preview_opts, opts)
  end
  return previewer
end

---@alias fzf-lua.preview.Spec function|{[1]: function?, fn: function?, field_index: string?}|string
---convert preview action functions to strings using our shell wrapper
---@param preview fzf-lua.preview.Spec
---@param opts table
---@return string?
Previewer.normalize_spec = function(preview, opts)
  if type(preview) == "function" then
    return (FzfLua.shell.stringify_data(preview, opts, "{}"))
  elseif type(preview) == "table" then
    preview = vim.tbl_extend("keep", preview, {
      fn = preview.fn or preview[1],
      -- by default we use current item only "{}"
      -- using "{+}" will send multiple selected items
      field_index = "{}",
    })
    if preview.type == "cmd" then
      return (FzfLua.shell.stringify_cmd(preview.fn, opts, preview.field_index))
    end
    return (FzfLua.shell.stringify_data(preview.fn, opts, preview.field_index))
  else
    return preview
  end
end

return Previewer
