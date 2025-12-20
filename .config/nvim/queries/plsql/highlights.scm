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

