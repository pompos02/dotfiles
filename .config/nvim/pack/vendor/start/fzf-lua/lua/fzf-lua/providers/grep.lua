---@diagnostic disable: param-type-mismatch
---@diagnostic disable-next-line: deprecated
local uv = vim.uv or vim.loop
local path = require "fzf-lua.path"
local core = require "fzf-lua.core"
local utils = require "fzf-lua.utils"
local config = require "fzf-lua.config"
local make_entry = require "fzf-lua.make_entry"

local M = {}

local get_grep_cmd = make_entry.get_grep_cmd

---@param opts fzf-lua.config.Grep|{}?
---@return thread?, string?, table?
M.grep = function(opts)
  ---@type fzf-lua.config.Grep
  opts = config.normalize_opts(opts, "grep")
  if not opts then return end

  -- we need this for `actions.grep_lgrep`
  opts.__ACT_TO = opts.__ACT_TO or M.live_grep

  if not opts.search and not opts.raw_cmd then
    -- resume implies no input prompt
    if opts.resume then
      opts.search = ""
    else
      -- if user did not provide a search term prompt for one
      local search = utils.input(opts.input_prompt)
      -- empty string is not falsy in lua, abort if the user cancels the input
      if search then
        opts.search = search
        -- save the search query for `resume=true`
        opts.__call_opts.search = search
      else
        return
      end
    end
  end

  if utils.has(opts, "fzf") and not opts.prompt and opts.search and #opts.search > 0 then
    opts.prompt = utils.ansi_from_hl(opts.hls.live_prompt, opts.search) .. " > "
  end

  -- get the grep command before saving the last search
  -- in case the search string is overwritten by 'rg_glob'
  opts.cmd = get_grep_cmd(opts, opts.search, opts.no_esc)
  if not opts.cmd then return end

  -- query was already parsed for globs inside 'get_grep_cmd'
  -- no need for our external headless instance to parse again
  opts.rg_glob = false

  -- search query in header line
  if type(opts._headers) == "table" then table.insert(opts._headers, "search") end
  opts = core.set_title_flags(opts, { "cmd" })
  opts = core.set_fzf_field_index(opts)
  return core.fzf_exec(opts.cmd, opts)
end

local function normalize_live_grep_opts(opts)
  -- disable treesitter as it collides with cmd regex highlighting
  opts = opts or {}
  opts._treesitter = false

  ---@type fzf-lua.config.Grep
  opts = config.normalize_opts(opts, "grep")
  if not opts then return end

  -- we need this for `actions.grep_lgrep`
  opts.__ACT_TO = opts.__ACT_TO or M.grep

  -- used by `actions.toggle_ignore', normalize_opts sets `__call_fn`
  -- to the calling function  which will resolve to this fn), we need
  -- to deref one level up to get to `live_grep_{mt|st}`
  opts.__call_fn = utils.__FNCREF2__()

  -- NOTE: no longer used since we hl the query with `FzfLuaLivePrompt`
  -- prepend prompt with "*" to indicate "live" query
  -- opts.prompt = type(opts.prompt) == "string" and opts.prompt or "> "
  -- if opts.live_ast_prefix ~= false then
  --   opts.prompt = opts.prompt:match("^%*") and opts.prompt or ("*" .. opts.prompt)
  -- end

  -- when using live_grep there is no "query", the prompt input
  -- is a regex expression and should be saved as last "search"
  -- this callback overrides setting "query" with "search"
  opts.__resume_set = function(what, val, o)
    if what == "query" then
      config.resume_set("search", val, { __resume_key = o.__resume_key })
      config.resume_set("no_esc", true, { __resume_key = o.__resume_key })
      utils.map_set(config, "__resume_data.last_query", val)
      -- also store query for `fzf_resume` (#963)
      utils.map_set(config, "__resume_data.opts.query", val)
      -- store in opts for convenience in action callbacks
      o.last_query = val
    else
      config.resume_set(what, val, { __resume_key = o.__resume_key })
    end
  end
  -- we also override the getter for the quickfix list name
  opts.__resume_get = function(what, o)
    return config.resume_get(
      what == "query" and "search" or what,
      { __resume_key = o.__resume_key })
  end

  -- when using an empty string grep (as in 'grep_project') or
  -- when switching from grep to live_grep using 'ctrl-g' users
  -- may find it confusing why is the last typed query not
  -- considered the last search so we find out if that's the
  -- case and use the last typed prompt as the grep string
  if not opts.search or #opts.search == 0 and (opts.query and #opts.query > 0) then
    -- fuzzy match query needs to be regex escaped
    opts.no_esc = nil
    opts.search = opts.query
    -- also replace in `__call_opts` for `resume=true`
    opts.__call_opts.query = nil
    opts.__call_opts.no_esc = nil
    opts.__call_opts.search = opts.query
  end

  -- interactive interface uses 'query' parameter
  opts.query = opts.search or ""
  if opts.search and #opts.search > 0 then
    -- escape unless the user requested not to
    if not opts.no_esc then
      opts.query = utils.rg_escape(opts.search)
    end
  end

  return opts
end

---@param opts fzf-lua.config.Grep|{}?
---@return thread?, string?, table?
M.live_grep = function(opts)
  ---@type fzf-lua.config.Grep
  opts = normalize_live_grep_opts(opts)
  if not opts then return end

  -- register opts._cmd, toggle_ignore/title_flag/--fixed-strings
  local cmd0 = get_grep_cmd(opts, core.fzf_query_placeholder, 2)

  -- if multiprocess is optional (=1) and no prpocessing is required
  -- use string contents (shell command), stringify_mt will use the
  -- command as is without the neovim headless wrapper
  local contents
  if opts.multiprocess == 1
      and not opts.fn_transform
      and not opts.fn_preprocess
      and not opts.fn_postprocess
  then
    contents = cmd0
  else
    -- since we're using function contents force multiprocess if optional
    opts.multiprocess = opts.multiprocess == 1 and true or opts.multiprocess
    contents = function(s, o)
      return FzfLua.make_entry.lgrep(s, o)
    end
  end

  -- search query in header line
  opts = core.set_title_flags(opts, { "cmd", "live" })
  opts = core.set_fzf_field_index(opts)
  core.fzf_live(contents, opts)
end

---@param opts fzf-lua.config.Grep|{}?
---@return thread?, string?, table?
M.grep_cword = function(opts)
  opts = opts or {}
  opts.no_esc = true
  -- match whole words only (#968)
  opts.search = [[\b]] .. utils.rg_escape(vim.fn.expand("<cword>")) .. [[\b]]
  return M.grep(opts)
end

M.grep_cWORD = function(opts)
  if not opts then opts = {} end
  opts.no_esc = true
  -- match neovim's WORD, match only surrounding space|SOL|EOL
  opts.search = [[(^|\s)]] .. utils.rg_escape(vim.fn.expand("<cWORD>")) .. [[($|\s)]]
  return M.grep(opts)
end

---@param opts fzf-lua.config.Grep|{}?
---@return thread?, string?, table?
M.grep_visual = function(opts)
  opts = opts or {}
  opts.search = utils.get_visual_selection()
  return M.grep(opts)
end

return M
