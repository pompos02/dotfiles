-- Save and reset 'cpoptions'
local cpo_save = vim.o.cpoptions
vim.cmd('set cpo&vim')

-- Conditional folding
if vim.g.plsql_fold == 1 then
  vim.opt_local.foldmethod = 'syntax'
  vim.b.undo_ftplugin = 'setlocal foldmethod<'
end

local function ensure_oracle_complete()
  if _G._oracle_complete then
    return
  end

  local keywords = {
    -- SQL
    "SELECT","INSERT","UPDATE","DELETE","MERGE","FROM","WHERE","GROUP","BY","HAVING","ORDER",
    "JOIN","LEFT","RIGHT","FULL","INNER","OUTER","IN","EXISTS","BETWEEN","LIKE","IS","NULL",
    "DISTINCT","UNION","ALL",

    -- PL/SQL
    "DECLARE","BEGIN","END","IF","THEN","ELSE","ELSIF","LOOP","FOR","WHILE","EXIT","RETURN",
    "EXCEPTION","WHEN","RAISE","PRAGMA",

    -- Types
    "NUMBER","VARCHAR2","DATE","CLOB","BLOB","BOOLEAN","RAW",

    -- Builtins
    "SYSDATE","SYSTIMESTAMP","NVL","NVL2","COALESCE","DECODE",
    "SUBSTR","INSTR","LENGTH","TRIM","RTRIM","LTRIM",
    "TO_CHAR","TO_DATE","TO_NUMBER",
    "COUNT","SUM","MIN","MAX","AVG",
    "DBMS_OUTPUT.PUTLINE"
  }

  _G._oracle_complete = function(findstart, base)
    local line = vim.api.nvim_get_current_line()
    local col = vim.fn.col(".") - 1

    if findstart == 1 then
      local start = col
      while start > 0 do
        local ch = line:sub(start, start)
        if not ch:match("[%w_]") then break end
        start = start - 1
      end
      return start
    end

    local res = {}
    local b = base:upper()

    for _, kw in ipairs(keywords) do
      if kw:find(b, 1, true) == 1 then
        table.insert(res, kw)
      end
    end

    return res
  end
end

ensure_oracle_complete()

-- Set omnifunc for PL/SQL buffers
vim.bo.omnifunc = "v:lua._oracle_complete"

-- Restore 'cpoptions'
vim.o.cpoptions = cpo_save

local undo = vim.b.undo_ftplugin or ""
if undo ~= "" then
  undo = undo .. " | "
end
vim.b.undo_ftplugin = undo .. "setlocal omnifunc<"
