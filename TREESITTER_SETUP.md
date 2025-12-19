# Treesitter setup (working path)

This documents the setup that is currently working in this repo: Treesitter highlighting and indentation using the native `pack` loader, without plugin managers.

## Prerequisites
- Neovim 0.11 (nightly) or newer (the branch checked out in `nvim-treesitter` requires this).
- `tree-sitter` CLI ≥ 0.26.1 (`tree-sitter --version` should show a build that supports `tree-sitter build`).
- C toolchain plus `curl` and `tar` available on PATH.

## Install the plugin (pack/start)
```bash
git clone https://github.com/nvim-treesitter/nvim-treesitter.git \
  ~/.config/nvim/pack/vendor/start/nvim-treesitter
```

## Neovim config snippet
Place this in `~/.config/nvim/init.lua` (matches the working config here):
```lua
do
    local ok, ts = pcall(require, "nvim-treesitter")
    if not ok then
        vim.notify("nvim-treesitter not found in runtimepath", vim.log.levels.WARN)
        return
    end

    local languages = {
        "bash", "sql", "c", "diff", "elixir", "heex", "eex", "go", "gomod", "gowork", "gosum",
        "html", "javascript", "jsdoc", "json", "jsonc", "lua", "luadoc", "luap",
        "markdown", "markdown_inline", "printf", "python", "query", "regex", "toml",
        "tsx", "typescript", "vim", "vimdoc", "xml", "yaml", "rust", "ron",
    }

    -- Install parsers/queries under stdpath("data")/site and prepend to rtp.
    ts.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })

    -- Optional: kick off installs for missing parsers.
    local installed = ts.get_installed()
    local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
    end, languages)
    if #missing > 0 then
        ts.install(missing, { summary = true })
    end

    -- Enable Treesitter highlight and indent on FileType.
    local group = vim.api.nvim_create_augroup("treesitter_enable", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable Treesitter features",
        group = group,
        callback = function(args)
            pcall(vim.treesitter.start, args.buf)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end
```

## Installing parsers
- On first start, the snippet will try to install any missing parsers listed in `languages`. If you prefer manual control, comment out that block and run:
  - `:lua require("nvim-treesitter").install({ "lua", "python", ... }, { summary = true })`
  - or `:TSInstall <lang>` per language.
- Check installed parsers with:
  - `:lua print(vim.inspect(require("nvim-treesitter").get_installed()))`
  - `:TSInstallInfo`

## Notes
- This uses the current nvim-treesitter branch without the legacy `nvim-treesitter.configs` API, so textobjects from `temp.lua` are not included here. To use textobjects, switch the plugin to the `master` branch and enable them there.***


## to setup the hilighing you should have this file insdiex ~/.local/share/nvim/site/queries/plsql/highlights.scm

```scm
; PL/SQL highlights for tree-sitter-plsql

; Comments
(comment_sl) @comment
(comment_ml) @comment

; Literals
(literal_string) @string
[(number) (float)] @number
[
  (kw_true)
  (kw_false)
] @boolean
(kw_null) @constant.builtin

; Identifiers and names
(item_declaration (identifier) @variable)
(item_declaration (identifier) @constant (kw_constant))
(parameter_declaration_element (identifier) @variable.parameter)
(referenced_element ref_name_parent: (identifier) @variable.member)
(referenced_element ref_name: (identifier) @variable)
(function_definition fnc_name: (identifier) @function)
(procedure_definition prc_name: (identifier) @function)
(cursor_definition (identifier) @function)
(ref_call (referenced_element ref_name: (identifier) @function.call))
(type_definition_record type_rec_name: (identifier) @type)
(type_definition_collection type_collection_name: (identifier) @type)

; Types and datatypes
[
  (kw_number) (kw_float) (kw_integer) (kw_smallint)
  (kw_varchar2) (kw_varchar) (kw_char) (kw_character)
  (kw_date) (kw_boolean) (kw_raw)
  (kw_record) (kw_table) (kw_type) (kw_datatype_type) (kw_datatype_rowtype)
] @type

; Core keywords
[
  (kw_select) (kw_from) (kw_where) (kw_group) (kw_by) (kw_having) (kw_order)
  (kw_insert) (kw_into) (kw_values)
  (kw_update) (kw_set)
  (kw_delete)
  (kw_merge)
  (kw_join) (kw_left) (kw_right) (kw_outer) (kw_inner)
  (kw_union) (kw_intersect) (kw_minus) (kw_distinct)
  (kw_create) (kw_alter) (kw_drop) (kw_replace)
  (kw_view) (kw_table) (kw_index) (kw_schema)
  (kw_package) (kw_function) (kw_procedure) (kw_trigger) (kw_type) (kw_body)
  (kw_begin) (kw_end) (kw_is) (kw_as) (kw_declare) (kw_exception)
  (kw_case) (kw_when) (kw_then) (kw_else) (kw_elsif)
  (kw_loop) (kw_while) (kw_for) (kw_if)
  (kw_return) (kw_returning)
  (kw_commit) (kw_rollback) (kw_savepoint)
  (kw_cursor) (kw_open) (kw_close) (kw_fetch) (kw_bulk) (kw_collect)
  (kw_constant) (kw_default)
  (kw_and) (kw_or) (kw_not) (kw_in) (kw_between) (kw_like)
  (kw_raise)
] @keyword
```
