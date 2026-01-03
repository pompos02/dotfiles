local M = {}

local function open_scratch(lines)
  vim.cmd("botright new")
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "git"
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function run(cmd)
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, output
  end
  return output
end

local function error_lines(prefix, output)
  local lines = { prefix }
  for _, line in ipairs(output or {}) do
    table.insert(lines, line)
  end
  return lines
end

M.show = function()
  if vim.fn.executable("git") ~= 1 then
    open_scratch({ "git is not available in PATH." })
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    open_scratch({ "Current buffer has no file path." })
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  local dir = vim.fn.fnamemodify(file, ":h")
  local base = vim.fn.fnamemodify(file, ":t")

  local blame_cmd = {
    "git",
    "-C",
    dir,
    "blame",
    "-L",
    line .. "," .. line,
    "--porcelain",
    "--",
    base,
  }

  local blame_out, blame_err = run(blame_cmd)
  if not blame_out then
    open_scratch(error_lines("Git blame failed:", blame_err))
    return
  end

  local first = blame_out[1] or ""
  local sha = first:match("^([0-9a-f]+)")
  if not sha then
    open_scratch({ "Could not parse blame output." })
    return
  end

  if sha:match("^0+$") then
    open_scratch({ "Uncommitted line." })
    return
  end

  local show_cmd = {
    "git",
    "-C",
    dir,
    "show",
    "-s",
    "--format=%H%n%an%n%ae%n%ar%n%B",
    sha,
  }

  local show_out, show_err = run(show_cmd)
  if not show_out then
    open_scratch(error_lines("Git show failed:", show_err))
    return
  end

  local lines = {
    "SHA: " .. (show_out[1] or sha),
    "Author: " .. (show_out[2] or "") .. " <" .. (show_out[3] or "") .. ">",
    "Date: " .. (show_out[4] or ""),
    "Message:",
  }

  for i = 5, #show_out do
    table.insert(lines, show_out[i])
  end

  open_scratch(lines)
end

vim.keymap.set("n", "<leader>gb", M.show, { desc = "Git blame line details" })

return M
