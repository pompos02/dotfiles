; PL/SQL + SQL highlights for tree-sitter-plsql

; Comments
(comment_sl) @comment
(comment_ml) @comment

; Literals
(literal_string) @string
(number) @number
(float) @number

; Booleans and null
[
  (kw_false)   (kw_true)
] @boolean
(kw_null) @constant.builtin

; Builtin constants
[
  (kw_current_user)   (kw_sysdate)
  (kw_systime)
] @constant.builtin

; Identifiers and names
(item_declaration (identifier) @variable)
(item_declaration
  (identifier) @constant
  (kw_constant)
  (#set! priority 110))
(parameter_declaration_element (identifier) @variable.parameter)
(parameter_name) @variable.parameter
(collection_variable) @variable
(iterator) @variable
(host_variable) @variable.builtin
(indicator_variable) @variable.builtin
(placeholder) @variable.builtin
(label) @label
(library_name) @namespace
(name_name) @namespace

(function_definition fnc_name: (identifier) @function)
(function_declaration fnc_name: (identifier) @function)
(procedure_definition prc_name: (identifier) @function)
(procedure_declaration prc_name: (identifier) @function)
(cursor_definition (identifier) @function)
(cursor_declaration (identifier) @function)
(element_spec_function_spec (identifier) @function)
(element_spec_procedure_spec (identifier) @function)
(element_spec_constructor_spec (identifier) @function)

(referenced_element
  ref_name_parent: (identifier) @variable.member)
(referenced_element
  ref_name: (identifier) @variable
  (#set! priority 90))
(ref_call
  (referenced_element ref_name: (identifier) @variable)
  (#set! priority 120))

(type_definition_record type_rec_name: (identifier) @type)
(type_definition_collection type_collection_name: (identifier) @type)
(type_definition_sub (identifier) @type)

; Fallback identifiers
((identifier) @variable
  (#set! priority 10))

; Types and datatypes
[
  (kw_bfile)   (kw_binary_double)   (kw_binary_float)   (kw_binary_integer)
  (kw_blob)   (kw_boolean)   (kw_char)   (kw_character)
  (kw_clob)   (kw_datatype_rowtype)   (kw_datatype_type)   (kw_date)
  (kw_dec)   (kw_decimal)   (kw_double)   (kw_float)
  (kw_int)   (kw_integer)   (kw_interval)   (kw_json_array_t)
  (kw_json_element_t)   (kw_json_object_t)   (kw_json_scalar_t)   (kw_long)
  (kw_natural)   (kw_naturaln)   (kw_nchar)   (kw_nclob)
  (kw_number)   (kw_numeric)   (kw_nvarchar2)   (kw_object)
  (kw_pls_integer)   (kw_positive)   (kw_positiven)   (kw_raw)
  (kw_real)   (kw_record)   (kw_rowid)   (kw_sdo_geometry)
  (kw_sdo_georaster)   (kw_sdo_topo_geometry)   (kw_simple_double)   (kw_simple_float)
  (kw_simple_integer)   (kw_smallint)   (kw_string)   (kw_time)
  (kw_timestamp)   (kw_uritype)   (kw_urowid)   (kw_varchar)
  (kw_varchar2)   (kw_varray)   (kw_xmltype)
] @type

; Keyword operators
[
  (kw_all)   (kw_and)   (kw_any)   (kw_between)
  (kw_exists)   (kw_in)   (kw_intersect)   (kw_is)
  (kw_like)   (kw_member)   (kw_minus)   (kw_not)
  (kw_of)   (kw_or)   (kw_union)
] @keyword.operator

; Conditionals
[
  (kw_case)   (kw_else)   (kw_elsif)
  (kw_if)   (kw_then)   (kw_when)
] @keyword.conditional

; Loops
[
  (kw_for)   (kw_forall)   (kw_loop)   (kw_while)
] @keyword.repeat

; Returns
[
  (kw_return)   (kw_returning)
] @keyword.return

; Exceptions
[
  (kw_exception)   (kw_raise)
] @exception

; Keywords
[
  (kw_access)   (kw_accessible)   (kw_add)   (kw_after)
  (kw_agent)   (kw_aggregate)   (kw_alter)   (kw_analytic)
  (kw_analyze)   (kw_anydata)   (kw_anydataset)   (kw_anytype)
  (kw_apply)   (kw_array)   (kw_as)   (kw_asc)
  (kw_associate)   (kw_asterisk)   (kw_attribute)   (kw_audit)
  (kw_authid)   (kw_badfile)   (kw_batch)   (kw_before)
  (kw_begin)   (kw_block)   (kw_body)   (kw_breadth)
  (kw_bulk)   (kw_by)   (kw_byte)   (kw_c)
  (kw_cascade)   (kw_charsetfrom)   (kw_charsetid)   (kw_check)
  (kw_clone)   (kw_close)   (kw_cluster)   (kw_collation)
  (kw_collect)   (kw_comment)   (kw_commit)   (kw_commtted)
  (kw_compile)   (kw_compound)   (kw_connect)   (kw_constant)
  (kw_constraint)   (kw_constructor)   (kw_container)   (kw_containers)
  (kw_context)   (kw_continue)   (kw_convert)   (kw_count)
  (kw_create)   (kw_cross)   (kw_crossedition)   (kw_cursor)
  (kw_cycle)   (kw_data)   (kw_database)   (kw_day)
  (kw_db_role_change)   (kw_ddl)   (kw_debug)   (kw_declare)
  (kw_default)   (kw_definer)   (kw_delete)   (kw_deleting)
  (kw_depth)   (kw_desc)   (kw_deterministic)   (kw_directory)
  (kw_disable)   (kw_disassociate)   (kw_discardfile)   (kw_distinct)
  (kw_drop)   (kw_duration)   (kw_each)   (kw_editionable)
  (kw_element)   (kw_enable)   (kw_end)   (kw_errors)
  (kw_exceptions)   (kw_execute)   (kw_exit)   (kw_extend)
  (kw_external)   (kw_fact)   (kw_fetch)   (kw_filter)
  (kw_final)   (kw_first)   (kw_follows)   (kw_force)
  (kw_foreign)   (kw_forward)   (kw_found)   (kw_from)
  (kw_full)   (kw_function)   (kw_goto)   (kw_grant)
  (kw_group)   (kw_hash)   (kw_having)   (kw_hierarchies)
  (kw_immediate)   (kw_immutable)   (kw_including)   (kw_increment)
  (kw_index)   (kw_indicator)   (kw_indices)   (kw_inner)
  (kw_insert)   (kw_inserting)   (kw_instantiable)   (kw_instead)
  (kw_into)   (kw_invalidate)   (kw_isolation)   (kw_isopen)
  (kw_java)   (kw_join)   (kw_json_key_list)   (kw_language)
  (kw_last)   (kw_lateral)   (kw_left)   (kw_length)
  (kw_level)   (kw_library)   (kw_limit)   (kw_local)
  (kw_location)   (kw_lock)   (kw_log)   (kw_logfile)
  (kw_logoff)   (kw_logon)   (kw_map)   (kw_matched)
  (kw_maxlen)   (kw_measure)   (kw_measures)   (kw_merge)
  (kw_metadata)   (kw_mode)   (kw_modify)   (kw_month)
  (kw_mutable)   (kw_name)   (kw_nested)   (kw_new)
  (kw_next)   (kw_noaudit)   (kw_nocopy)   (kw_nocycle)
  (kw_none)   (kw_noneditionable)   (kw_notfound)   (kw_nowait)
  (kw_nulls)   (kw_offset)   (kw_oid)   (kw_old)
  (kw_on)   (kw_only)   (kw_open)   (kw_option)
  (kw_order)   (kw_others)   (kw_out)   (kw_outer)
  (kw_overriding)   (kw_package)   (kw_pairs)   (kw_parallel_enable)
  (kw_parameters)   (kw_parent)   (kw_partition)   (kw_percent)
  (kw_persistable)   (kw_pipe)   (kw_pipelined)   (kw_pluggable)
  (kw_precedes)   (kw_precision)   (kw_prior)   (kw_procedure)
  (kw_range)   (kw_read)   (kw_reference)   (kw_referencing)
  (kw_reject)   (kw_relies_on)   (kw_rename)   (kw_repeat)
  (kw_replace)   (kw_reset)   (kw_result)   (kw_result_cache)
  (kw_reuse)   (kw_reverse)   (kw_revoke)   (kw_right)
  (kw_rollback)   (kw_row)   (kw_rowcount)   (kw_rows)
  (kw_sample)   (kw_savepoint)   (kw_schema)   (kw_search)
  (kw_second)   (kw_seed)   (kw_segment)   (kw_select)
  (kw_self)   (kw_serializable)   (kw_servererror)   (kw_set)
  (kw_settings)   (kw_shards)   (kw_shutdown)   (kw_siblings)
  (kw_signtype)   (kw_specification)   (kw_start)   (kw_startup)
  (kw_statement)   (kw_static)   (kw_statistics)   (kw_struct)
  (kw_subpartition)   (kw_substitutable)   (kw_subtype)   (kw_suspend)
  (kw_sys)   (kw_table)   (kw_tdo)   (kw_ties)
  (kw_to)   (kw_transaction)   (kw_trigger)   (kw_trim)
  (kw_truncate)   (kw_type)   (kw_under)   (kw_unique)
  (kw_unlimited)   (kw_unplug)   (kw_update)   (kw_updating)
  (kw_use)   (kw_using)   (kw_using_nls_comp)   (kw_validate)
  (kw_value)   (kw_values)   (kw_varying)   (kw_view)
  (kw_wait)   (kw_where)   (kw_with)   (kw_work)
  (kw_write)   (kw_year)   (kw_zone)
] @keyword

; Operators
[
  "!=" "%" "*" "**"
  "+" "-" "/" "<"
  "<=" "<>" "=" ">"
  ">=" ":=" "=>" ".."
  "||" "^=" "~="
] @operator

; Punctuation
[
  "(" ")" "<<" ">>"
] @punctuation.bracket
[
  "," ";" "." ":"
] @punctuation.delimiter
["@"] @punctuation.special
