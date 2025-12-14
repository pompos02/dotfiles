local core = require "fzf-lua.core"
local utils = require "fzf-lua.utils"
local config = require "fzf-lua.config"

local M = {}

-- LSP handler table pared down to references only
local handlers = {
  ["references"] = {
    method = "textDocument/references",
    label = "References",
    prep = "lsp.buf_request_sync",
    action = function(entries, opts)
      local winopts = opts.winopts or {}
      local bufopts = { bufnr = utils.CTX().bufnr, lnum = 1, col = 0 }
      return utils.qf_populate_entries(entries, winopts, bufopts)
    end,
  },
}

local function check_capabilities(handler, silent)
  local clients = utils.lsp_get_clients({ bufnr = utils.CTX().bufnr })
  local num_clients = 0
  for _, client in pairs(clients) do
    if client:supports_method(handler.prep or handler.method) then
      num_clients = num_clients + 1
    end
  end
  if num_clients > 0 then return num_clients end
  utils.clear_CTX()
  if utils.tbl_isempty(clients) then
    if not silent then utils.info("LSP: no client attached") end
  elseif not silent then
    utils.info("LSP: no attached client supports method '%s'", handler.method)
  end
end

local function normalize_lsp_opts(opts, cfg, __resume_key)
  opts = config.normalize_opts(opts, cfg, __resume_key)
  if not opts then return end
  if not opts.cwd or #opts.cwd == 0 then
    opts.cwd = utils.cwd()
  elseif opts.cwd_only == nil then
    opts.cwd_only = true
  end
  return opts
end

local function gen_lsp_contents(opts)
  utils.set_info({ cmd = opts.lsp_handler.label, fnc = opts.lsp_handler.method })
  local ctx = utils.CTX()
  opts.lsp_params = opts.lsp_params or {}
  opts.lsp_params.context = { includeDeclaration = true }
  opts.lsp_params.textDocument = vim.lsp.util.make_text_document_params(ctx.bufnr)

  local count = check_capabilities(opts.lsp_handler)
  if not count then return end

  local results = {}
  local outstanding = 0
  local function schedule_request(client)
    outstanding = outstanding + 1
    client.request(opts.lsp_handler.method, opts.lsp_params, function(err, res, _, _)
      outstanding = outstanding - 1
      if err == nil and res and not vim.tbl_isempty(res) then
        for _, loc in ipairs(res) do
          if loc.range then
            table.insert(results, loc)
          elseif loc.targetRange then
            table.insert(results, {
              uri = loc.targetUri,
              range = loc.targetRange,
            })
          end
        end
      end
    end, ctx.bufnr)
  end

  for _, client in pairs(utils.lsp_get_clients({ bufnr = ctx.bufnr })) do
    if client:supports_method(opts.lsp_handler.method) then
      schedule_request(client)
    end
  end

  vim.wait(opts.async_or_timeout or 5000, function() return outstanding == 0 end)

  if vim.tbl_isempty(results) then
    utils.clear_CTX()
    if not opts.silent then
      utils.info(("No %s found"):format(opts.lsp_handler.label:lower()))
    end
    return
  end

  local items = {}
  for _, loc in ipairs(results) do
    local entry = utils.lsp_location_entry(loc, opts)
    if entry then table.insert(items, entry) end
  end

  opts.__contents = utils.tbl_map(function(e) return e.text end, items)
  opts = core.set_fzf_field_index(opts)
  opts._LSP_ENTRIES = items
  opts.actions = opts.actions or {}
  opts.actions.enter = function(selected)
    local idx = tonumber(selected[1]:match("(%d+)$"))
    local item = idx and items[idx]
    if item then
      utils.jump_to_location(item, opts)
    end
  end
  return opts
end

---@param opts fzf-lua.config.Lsp|{}?
---@return thread?, string?, table?
M.references = function(opts)
  opts = normalize_lsp_opts(opts, "lsp")
  if not opts then return end
  opts.lsp_handler = handlers.references
  opts = gen_lsp_contents(opts)
  if not opts or not opts.__contents then return end
  return core.fzf_exec(opts.__contents, opts)
end

return M
