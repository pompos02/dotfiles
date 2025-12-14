local path = require "fzf-lua.path"
local utils = require "fzf-lua.utils"
local actions = require "fzf-lua.actions"
local previewers = require "fzf-lua.previewer"

local M = {}

function M._default_previewer_fn()
  return "builtin"
end

-- minimal highlight defaults
M.defaults = {
  __HLS = {},
  nbsp = utils.nbsp,
  winopts = {
    height = 0.85,
    width = 0.80,
    row = 0.35,
    col = 0.55,
    border = "rounded",
    zindex = 50,
    backdrop = 60,
    fullscreen = false,
    title_pos = "center",
    treesitter = {
      enabled = utils.__HAS_NVIM_010,
      fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" },
    },
    preview = {
      default = "builtin",
      border = "rounded",
      wrap = false,
      hidden = false,
      vertical = "down:45%",
      horizontal = "right:60%",
      layout = "flex",
      flip_columns = 100,
      title = true,
      title_pos = "center",
      scrollbar = "border",
      scrolloff = -1,
      delay = 20,
      winopts = {
        number = true,
        relativenumber = false,
        cursorline = true,
        cursorlineopt = "both",
        cursorcolumn = false,
        signcolumn = "no",
        list = false,
        foldenable = false,
        foldmethod = "manual",
        scrolloff = 0,
      },
    },
  },
  keymap = {
    builtin = {
      ["<M-Esc>"] = "hide",
      ["<F1>"] = "toggle-help",
      ["<F2>"] = "toggle-fullscreen",
      ["<F3>"] = "toggle-preview-wrap",
      ["<F4>"] = "toggle-preview",
      ["<F5>"] = "toggle-preview-cw",
      ["<F6>"] = "toggle-preview-behavior",
      ["<F7>"] = "toggle-preview-ts-ctx",
      ["<F8>"] = "preview-ts-ctx-dec",
      ["<S-Left>"] = "preview-reset",
      ["<S-down>"] = "preview-page-down",
      ["<S-up>"] = "preview-page-up",
      ["<M-S-down>"] = "preview-down",
      ["<M-S-up>"] = "preview-up",
    },
    fzf = {
      ["ctrl-z"] = "abort",
      ["ctrl-u"] = "unix-line-discard",
      ["ctrl-f"] = "half-page-down",
      ["ctrl-b"] = "half-page-up",
      ["ctrl-a"] = "beginning-of-line",
      ["ctrl-e"] = "end-of-line",
      ["alt-a"] = "toggle-all",
      ["alt-g"] = "first",
      ["alt-G"] = "last",
      ["f3"] = "toggle-preview-wrap",
      ["f4"] = "toggle-preview",
      ["shift-down"] = "preview-page-down",
      ["shift-up"] = "preview-page-up",
      ["alt-shift-down"] = "preview-down",
      ["alt-shift-up"] = "preview-up",
    },
  },
  actions = {
    files = {
      ["enter"] = actions.file_edit_or_qf,
      ["ctrl-s"] = actions.file_split,
      ["ctrl-v"] = actions.file_vsplit,
      ["ctrl-t"] = actions.file_tabedit,
      ["alt-q"] = actions.file_sel_to_qf,
      ["alt-Q"] = actions.file_sel_to_ll,
      ["alt-i"] = { fn = actions.toggle_ignore, reuse = true, header = false },
      ["alt-h"] = { fn = actions.toggle_hidden, reuse = true, header = false },
      ["alt-f"] = { fn = actions.toggle_follow, reuse = true, header = false },
    },
    buffers = {},
  },
  fzf_opts = {
    ["--ansi"] = true,
    ["--info"] = "inline-right",
    ["--height"] = "100%",
    ["--layout"] = "reverse",
    ["--border"] = "none",
    ["--highlight-line"] = true,
  },
  previewers = {
    cat = { cmd = "cat", args = "-n", _ctor = previewers.fzf.cmd },
    bat = {
      cmd = function() return vim.fn.executable("batcat") == 1 and "batcat" or "bat" end,
      args = "--color=always --style=numbers,changes",
      _ctor = previewers.fzf.bat_async,
    },
    head = { cmd = "head", args = nil, _ctor = previewers.fzf.head },
    help_tags = { _ctor = previewers.builtin.help_tags },
    builtin = {
      syntax = true,
      syntax_delay = 0,
      syntax_limit_l = 0,
      syntax_limit_b = 1024 * 1024,
      limit_b = 1024 * 1024 * 10,
      treesitter = { enabled = true, disabled = {}, context = { max_lines = 1, trim_scope = "inner" } },
      title_fnamemodify = function(s) return path.tail(s) end,
      _ctor = previewers.builtin.buffer_or_file,
    },
  },
}

-- Files picker
M.defaults.files = {
  previewer = M._default_previewer_fn,
  prompt = "> ",
  multiprocess = 1,
  git_icons = true,
  file_icons = 1,
  color_icons = true,
  fd_opts = "--color=never --type f --hidden --follow --exclude .git",
  rg_opts = "--color=never --files --hidden --follow -g '!.git'",
  find_opts = "-type f",
  dir_opts = "/b /s",
  actions = M.defaults.actions.files,
}

-- Grep picker (used by live_grep and grep_cword variants)
M.defaults.grep = {
  previewer = M._default_previewer_fn,
  input_prompt = "Grep For> ",
  multiprocess = 1,
  _type = "file",
  file_icons = 1,
  color_icons = true,
  git_icons = false,
  fzf_opts = { ["--multi"] = true },
  grep_opts = utils.is_darwin()
      and "--binary-files=without-match --line-number --recursive --color=always --extended-regexp -e"
      or "--binary-files=without-match --line-number --recursive --color=always --perl-regexp -e",
  rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
  rg_glob = 1,
  _actions = function() return M.defaults.actions.files end,
  actions = { ["ctrl-g"] = { actions.grep_lgrep } },
  glob_flag = "--iglob",
  glob_separator = "%s%-%-",
  _treesitter = true,
  _headers = { "actions", "cwd" },
}

-- Helptags
M.defaults.helptags = {
  actions = {
    ["enter"] = actions.help,
    ["ctrl-s"] = actions.help,
    ["ctrl-v"] = actions.help_vert,
    ["ctrl-t"] = actions.help_tab,
  },
  fzf_opts = {
    ["--no-multi"] = true,
    ["--delimiter"] = string.format("[%s]", utils.nbsp),
    ["--with-nth"] = "..-2",
    ["--tiebreak"] = "begin",
  },
  previewer = { _ctor = previewers.builtin.help_tags },
}

-- Keymaps
M.defaults.keymaps = {
  previewer = { _ctor = previewers.builtin.keymaps },
  winopts = { preview = { layout = "vertical" } },
  fzf_opts = { ["--tiebreak"] = "index", ["--no-multi"] = true },
  ignore_patterns = { "^<SNR>", "^<Plug>" },
  show_desc = true,
  show_details = true,
  actions = {
    ["enter"] = actions.keymap_apply,
    ["ctrl-s"] = actions.keymap_split,
    ["ctrl-v"] = actions.keymap_vsplit,
    ["ctrl-t"] = actions.keymap_tabedit,
  },
}

-- Minimal LSP defaults (references only)
M.defaults.lsp = {
  previewer = M._default_previewer_fn,
  file_icons = 1,
  color_icons = true,
  git_icons = false,
  async_or_timeout = 5000,
  jump1 = true,
  jump1_action = actions.file_edit,
  fzf_opts = { ["--multi"] = true },
  _actions = function() return M.defaults.actions.files end,
  _cached_hls = { "path_colnr", "path_linenr" },
  _treesitter = true,
  _uri = true,
  _headers = { "actions", "regex_filter" },
}

-- Profiles picker (optional)
M.defaults.profiles = {
  previewer = M._default_previewer_fn,
  fzf_opts = {
    ["--delimiter"] = "[:]",
    ["--with-nth"] = "-1..",
    ["--tiebreak"] = "begin",
    ["--no-multi"] = true,
  },
  actions = { ["enter"] = actions.apply_profile },
}

return M
