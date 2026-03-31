#!/usr/bin/env bash

THEME_HOME="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
THEME_CURRENT_FILE="${THEME_HOME}/current"
THEME_ENV_FILE="${THEME_HOME}/current_theme.env"
THEME_FZF_FILE="${THEME_HOME}/current_fzf.sh"
THEME_THEMES_DIR="${THEME_HOME}/themes"
THEME_NVIM_INIT_FILE="${HOME}/.config/nvim/init.lua"
THEME_KITTY_CURRENT_FILE="${HOME}/.config/kitty/current-theme.conf"
THEME_WINDOWS_TERMINAL_SETTINGS_PATH="${WINDOWS_TERMINAL_SETTINGS_PATH:-/mnt/c/Users/yiann/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json}"
THEME_WINDOWS_DARK_SCHEME="${THEME_WINDOWS_DARK_SCHEME:-Custom Dark}"
THEME_WINDOWS_LIGHT_SCHEME="${THEME_WINDOWS_LIGHT_SCHEME:-Custom Light}"

_theme_required_meta_keys=(name nvim_name variant)
_theme_required_palette_keys=(
	background
	background_alt
	surface
	surface_alt
	overlay
	muted
	subtle
	foreground
	red
	yellow
	orange
	blue
	cyan
	lavender
	magenta
	green
	highlight
	selection
	border
)
_theme_export_vars=(
	THEME_NAME
	THEME_NVIM_NAME
	THEME_KDE_NAME
	THEME_VARIANT
	THEME_BACKGROUND
	THEME_BACKGROUND_ALT
	THEME_SURFACE
	THEME_SURFACE_ALT
	THEME_OVERLAY
	THEME_MUTED
	THEME_SUBTLE
	THEME_FOREGROUND
	THEME_RED
	THEME_YELLOW
	THEME_ORANGE
	THEME_BLUE
	THEME_CYAN
	THEME_LAVENDER
	THEME_MAGENTA
	THEME_GREEN
	THEME_HIGHLIGHT
	THEME_SELECTION
	THEME_BORDER
)

_theme_trim() {
	local value="$1"

	value="${value#"${value%%[![:space:]]*}"}"
	value="${value%"${value##*[![:space:]]}"}"
	printf '%s\n' "$value"
}

_theme_strip_quotes() {
	local value="$1"

	if [[ "$value" == \"*\" && "$value" == *\" ]]; then
		value="${value:1:${#value}-2}"
	fi

	printf '%s\n' "$value"
}

_theme_escape_sed_replacement() {
	local value="$1"

	value="${value//\\/\\\\}"
	value="${value//&/\\&}"
	printf '%s\n' "$value"
}

_theme_escape_ere() {
	printf '%s\n' "$1" | sed 's/[][(){}.^$*+?|\\/-]/\\&/g'
}

theme_list() {
	local path name

	shopt -s nullglob
	for path in "$THEME_THEMES_DIR"/*.ini; do
		name="${path##*/}"
		printf '%s\n' "${name%.ini}"
	done | sort
	shopt -u nullglob
}

theme_current_name() {
	local name

	if [[ -f "$THEME_CURRENT_FILE" ]]; then
		IFS= read -r name <"$THEME_CURRENT_FILE"
		name="$(_theme_trim "$name")"
		if [[ -n "$name" ]]; then
			printf '%s\n' "$name"
			return 0
		fi
	fi

	while IFS= read -r name; do
		printf '%s\n' "$name"
		return 0
	done < <(theme_list)

	printf 'No themes found in %s\n' "$THEME_THEMES_DIR" >&2
	return 1
}

theme_file() {
	local name="$1"
	local file="$THEME_THEMES_DIR/$name.ini"

	if [[ ! -f "$file" ]]; then
		printf 'Theme file not found: %s\n' "$file" >&2
		return 1
	fi

	printf '%s\n' "$file"
}

_theme_file_value() {
	local file="$1"
	local wanted_section="$2"
	local wanted_key="$3"
	local section line key value

	section=''
	while IFS= read -r line || [[ -n "$line" ]]; do
		line="$(_theme_trim "$line")"

		[[ -z "$line" ]] && continue
		[[ "$line" == ';'* ]] && continue
		[[ "$line" == '#'* ]] && continue

		if [[ "$line" =~ ^\[([a-z_]+)\]$ ]]; then
			section="${BASH_REMATCH[1]}"
			continue
		fi

		[[ "$section" == "$wanted_section" ]] || continue

		if [[ "$line" =~ ^([a-z_]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
			key="${BASH_REMATCH[1]}"
			value="$(_theme_strip_quotes "$(_theme_trim "${BASH_REMATCH[2]}")")"
			if [[ "$key" == "$wanted_key" ]]; then
				printf '%s\n' "$value"
				return 0
			fi
		fi
	done <"$file"

	return 1
}

theme_display_name() {
	local name="$1"
	local file value

	file="$(theme_file "$name")" || return 1
	value="$(_theme_file_value "$file" meta name 2>/dev/null || true)"
	printf '%s\n' "${value:-$name}"
}

theme_reset_vars() {
	local var_name

	for var_name in "${_theme_export_vars[@]}"; do
		unset "$var_name"
	done
}

_theme_set_var() {
	local key="$1"
	local value="$2"
	local var_name="THEME_${key^^}"

	printf -v "$var_name" '%s' "$value"
	export "$var_name"
}

_theme_validate_loaded() {
	local key var_name

	for key in "${_theme_required_meta_keys[@]}"; do
		var_name="THEME_${key^^}"
		if [[ -z "${!var_name:-}" ]]; then
			printf 'Theme is missing required meta key: %s\n' "$key" >&2
			return 1
		fi
	done

	for key in "${_theme_required_palette_keys[@]}"; do
		var_name="THEME_${key^^}"
		if [[ -z "${!var_name:-}" ]]; then
			printf 'Theme is missing required palette key: %s\n' "$key" >&2
			return 1
		fi
	done

	case "$THEME_VARIANT" in
	dark | light) ;;
	*)
		printf 'Theme variant must be dark or light: %s\n' "$THEME_VARIANT" >&2
		return 1
		;;
	esac
}

theme_load() {
	local name="$1"
	local theme_file_path section line key value

	theme_file_path="$(theme_file "$name")" || return 1
	section=''
	theme_reset_vars

	while IFS= read -r line || [[ -n "$line" ]]; do
		line="$(_theme_trim "$line")"

		[[ -z "$line" ]] && continue
		[[ "$line" == ';'* ]] && continue
		[[ "$line" == '#'* ]] && continue

		if [[ "$line" =~ ^\[([a-z_]+)\]$ ]]; then
			section="${BASH_REMATCH[1]}"
			case "$section" in
			meta | palette) ;;
			*)
				printf 'Unsupported theme section [%s] in %s\n' "$section" "$theme_file_path" >&2
				return 1
				;;
			esac
			continue
		fi

		if [[ ! "$line" =~ ^([a-z_]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
			printf 'Invalid theme line in %s: %s\n' "$theme_file_path" "$line" >&2
			return 1
		fi

		key="${BASH_REMATCH[1]}"
		value="$(_theme_strip_quotes "$(_theme_trim "${BASH_REMATCH[2]}")")"

		case "$section" in
		meta | palette)
			_theme_set_var "$key" "$value"
			;;
		*)
			printf 'Theme key defined outside a supported section in %s: %s\n' "$theme_file_path" "$line" >&2
			return 1
			;;
		esac
	done <"$theme_file_path"

	_theme_validate_loaded
}

theme_load_current() {
	local name

	name="$(theme_current_name)" || return 1
	theme_load "$name"
}

theme_write_env() {
	local var_name

	: "${THEME_NAME:?theme_write_env requires a loaded theme}"
	: "${THEME_NVIM_NAME:?theme_write_env requires a loaded theme}"
	: "${THEME_VARIANT:?theme_write_env requires a loaded theme}"

	{
		printf '# Generated by %s\n' "${BASH_SOURCE[0]}"
		for var_name in "${_theme_export_vars[@]}"; do
			printf 'export %s=%q\n' "$var_name" "${!var_name:-}"
		done
	} >"$THEME_ENV_FILE"
}

theme_write_fzf() {
	local arg
	local -a fzf_args=(
		"--color=fg:${THEME_FOREGROUND},bg:${THEME_BACKGROUND}"
		"--color=fg+:${THEME_FOREGROUND},bg+:${THEME_SELECTION}"
		"--color=hl:${THEME_CYAN}:reverse:bold,hl+:${THEME_CYAN}:reverse:bold"
		"--color=info:${THEME_MUTED},separator:${THEME_BORDER},scrollbar:${THEME_BORDER},border:${THEME_BORDER}"
		"--color=prompt:${THEME_GREEN},pointer:${THEME_MAGENTA},marker:${THEME_MAGENTA},spinner:${THEME_CYAN},header:${THEME_SUBTLE}"
	)

	{
		printf '# Generated by %s\n' "${BASH_SOURCE[0]}"
		printf 'FZF_THEME_ARGS=(\n'
		for arg in "${fzf_args[@]}"; do
			printf '\t%q\n' "$arg"
		done
		printf ')\n'
	} >"$THEME_FZF_FILE"
}

theme_write_shell_files() {
	theme_write_env
	theme_write_fzf
}

theme_source_fzf() {
	theme_ensure_shell_files || return 1
	# shellcheck disable=SC1090
	source "$THEME_FZF_FILE"
}

theme_platform() {
	local os

	os="$(uname -s)"
	if [[ "$os" == "Linux" && -d /mnt/c/Windows ]]; then
		printf 'wsl\n'
	elif [[ "$os" == "Linux" ]]; then
		printf 'linux\n'
	else
		printf 'unsupported\n'
	fi
}

theme_apply_nvim_init() {
	local variant colorscheme

	[[ -f "$THEME_NVIM_INIT_FILE" ]] || return 0

	variant="$(_theme_escape_sed_replacement "$THEME_VARIANT")"
	colorscheme="$(_theme_escape_sed_replacement "$THEME_NVIM_NAME")"

	sed -i -E "s|^([[:space:]]*vim\\.opt\\.background[[:space:]]*=[[:space:]]*).*$|\\1\"${variant}\"|" "$THEME_NVIM_INIT_FILE"
	sed -i -E "s|^([[:space:]]*vim\\.cmd\\.colorscheme\\()[^)]*(\\).*)$|\\1\"${colorscheme}\"\\2|" "$THEME_NVIM_INIT_FILE"
}

theme_apply_running_nvim() {
	local server remote_cmd

	[[ -n "${XDG_RUNTIME_DIR:-}" ]] || return 0

	remote_cmd="<Esc>:set background=${THEME_VARIANT}<CR>:colorscheme ${THEME_NVIM_NAME}<CR>"
	shopt -s nullglob
	for server in "$XDG_RUNTIME_DIR"/nvim.*; do
		nvim --server "$server" --remote-send "$remote_cmd" >/dev/null 2>&1 || true
	done
	shopt -u nullglob
}

_theme_kitty_line() {
	printf '%-24s %s\n' "$1" "$2"
}

theme_write_kitty() {
	{
		printf '# vim:ft=kitty\n\n'
		printf '## Generated by %s\n' "${BASH_SOURCE[0]}"
		printf '## name: %s\n' "$THEME_NAME"
		printf '## variant: %s\n\n' "$THEME_VARIANT"
		printf '# The basic colors\n'
		_theme_kitty_line foreground "$THEME_FOREGROUND"
		_theme_kitty_line background "$THEME_BACKGROUND"
		_theme_kitty_line selection_foreground "$THEME_FOREGROUND"
		_theme_kitty_line selection_background "$THEME_SELECTION"
		printf '\n# Cursor colors\n'
		_theme_kitty_line cursor "$THEME_FOREGROUND"
		_theme_kitty_line cursor_text_color "$THEME_BACKGROUND"
		printf '\n# kitty window border colors\n'
		_theme_kitty_line active_border_color "$THEME_BLUE"
		_theme_kitty_line inactive_border_color "$THEME_BORDER"
		printf '\n# Tab bar colors\n'
		_theme_kitty_line active_tab_foreground "$THEME_FOREGROUND"
		_theme_kitty_line active_tab_background "$THEME_SURFACE"
		_theme_kitty_line inactive_tab_foreground "$THEME_MUTED"
		_theme_kitty_line inactive_tab_background "$THEME_BACKGROUND_ALT"
		printf '\n# The basic 16 colors\n\n'
		printf '# black\n'
		_theme_kitty_line color0 "$THEME_BACKGROUND_ALT"
		_theme_kitty_line color8 "$THEME_MUTED"
		printf '\n# red\n'
		_theme_kitty_line color1 "$THEME_RED"
		_theme_kitty_line color9 "$THEME_RED"
		printf '\n# green\n'
		_theme_kitty_line color2 "$THEME_GREEN"
		_theme_kitty_line color10 "$THEME_GREEN"
		printf '\n# yellow\n'
		_theme_kitty_line color3 "$THEME_YELLOW"
		_theme_kitty_line color11 "$THEME_ORANGE"
		printf '\n# blue\n'
		_theme_kitty_line color4 "$THEME_BLUE"
		_theme_kitty_line color12 "$THEME_LAVENDER"
		printf '\n# magenta\n'
		_theme_kitty_line color5 "$THEME_MAGENTA"
		_theme_kitty_line color13 "$THEME_LAVENDER"
		printf '\n# cyan\n'
		_theme_kitty_line color6 "$THEME_CYAN"
		_theme_kitty_line color14 "$THEME_CYAN"
		printf '\n# white\n'
		_theme_kitty_line color7 "$THEME_SURFACE_ALT"
		_theme_kitty_line color15 "$THEME_FOREGROUND"
	} >"$THEME_KITTY_CURRENT_FILE"
}

theme_apply_kitty() {
	theme_write_kitty

	if command -v kitty >/dev/null 2>&1; then
		kitty @ load-config >/dev/null 2>&1 || true
	fi
}

_theme_windows_terminal_scheme_name() {
	case "$THEME_VARIANT" in
	dark)
		printf '%s\n' "$THEME_WINDOWS_DARK_SCHEME"
		;;
	light)
		printf '%s\n' "$THEME_WINDOWS_LIGHT_SCHEME"
		;;
	esac
}

_theme_update_windows_terminal_scheme_value() {
	local scheme_name="$1"
	local key="$2"
	local value="$3"
	local escaped_scheme escaped_key escaped_value

	escaped_scheme="$(_theme_escape_ere "$scheme_name")"
	escaped_key="$(_theme_escape_ere "$key")"
	escaped_value="$(_theme_escape_sed_replacement "$value")"

	sed -i -E "/\"name\"[[:space:]]*:[[:space:]]*\"${escaped_scheme}\"/,/}/ s|(\"${escaped_key}\"[[:space:]]*:[[:space:]]*\")[^\"]*(\".*)|\\1${escaped_value}\\2|" "$THEME_WINDOWS_TERMINAL_SETTINGS_PATH"
}

theme_apply_windows_terminal() {
	local scheme_name escaped_scheme escaped_value

	[[ -f "$THEME_WINDOWS_TERMINAL_SETTINGS_PATH" ]] || return 0

	scheme_name="$(_theme_windows_terminal_scheme_name)"
	escaped_scheme="$(_theme_escape_ere "$scheme_name")"

	if ! grep -q "\"name\"[[:space:]]*:[[:space:]]*\"${escaped_scheme}\"" "$THEME_WINDOWS_TERMINAL_SETTINGS_PATH"; then
		printf 'Windows Terminal scheme not found: %s\n' "$scheme_name" >&2
		return 0
	fi

	_theme_update_windows_terminal_scheme_value "$scheme_name" background "$THEME_BACKGROUND"
	_theme_update_windows_terminal_scheme_value "$scheme_name" black "$THEME_BACKGROUND_ALT"
	_theme_update_windows_terminal_scheme_value "$scheme_name" blue "$THEME_BLUE"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightBlack "$THEME_MUTED"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightBlue "$THEME_LAVENDER"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightCyan "$THEME_CYAN"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightGreen "$THEME_GREEN"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightPurple "$THEME_LAVENDER"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightRed "$THEME_RED"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightWhite "$THEME_FOREGROUND"
	_theme_update_windows_terminal_scheme_value "$scheme_name" brightYellow "$THEME_ORANGE"
	_theme_update_windows_terminal_scheme_value "$scheme_name" cursorColor "$THEME_FOREGROUND"
	_theme_update_windows_terminal_scheme_value "$scheme_name" cyan "$THEME_CYAN"
	_theme_update_windows_terminal_scheme_value "$scheme_name" foreground "$THEME_FOREGROUND"
	_theme_update_windows_terminal_scheme_value "$scheme_name" green "$THEME_GREEN"
	_theme_update_windows_terminal_scheme_value "$scheme_name" purple "$THEME_MAGENTA"
	_theme_update_windows_terminal_scheme_value "$scheme_name" red "$THEME_RED"
	_theme_update_windows_terminal_scheme_value "$scheme_name" selectionBackground "$THEME_SELECTION"
	_theme_update_windows_terminal_scheme_value "$scheme_name" white "$THEME_SURFACE_ALT"
	_theme_update_windows_terminal_scheme_value "$scheme_name" yellow "$THEME_YELLOW"

	escaped_value="$(_theme_escape_sed_replacement "$scheme_name")"
	sed -i -E "s|^([[:space:]]*\"colorScheme\"[[:space:]]*:[[:space:]]*\")[^\"]*(\".*)|\\1${escaped_value}\\2|" "$THEME_WINDOWS_TERMINAL_SETTINGS_PATH"
	sed -i -E "s|^([[:space:]]*\"theme\"[[:space:]]*:[[:space:]]*\")[^\"]*(\".*)|\\1${THEME_VARIANT}\\2|" "$THEME_WINDOWS_TERMINAL_SETTINGS_PATH"
}

theme_apply_kde() {
	[[ -n "${THEME_KDE_NAME:-}" ]] || return 0
	if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
		plasma-apply-colorscheme "$THEME_KDE_NAME" >/dev/null 2>&1 || true
	fi
}

theme_apply_loaded() {
	local platform

	: "${THEME_NAME:?theme_apply_loaded requires a loaded theme}"
	: "${THEME_NVIM_NAME:?theme_apply_loaded requires a loaded theme}"
	: "${THEME_VARIANT:?theme_apply_loaded requires a loaded theme}"

	theme_write_shell_files
	theme_apply_nvim_init
	theme_apply_running_nvim

	platform="$(theme_platform)"
	case "$platform" in
	wsl)
		theme_apply_windows_terminal
		;;
	linux)
		theme_apply_kitty
		theme_apply_kde
		;;
	esac
}

theme_apply() {
	local name="$1"

	theme_load "$name" || return 1
	printf '%s\n' "$name" >"$THEME_CURRENT_FILE"
	theme_apply_loaded
}

theme_apply_current() {
	local name

	name="$(theme_current_name)" || return 1
	theme_apply "$name"
}

theme_picker_entries() {
	local name display current suffix

	current="$(theme_current_name 2>/dev/null || true)"
	while IFS= read -r name; do
		display="$(theme_display_name "$name")"
		suffix=''
		if [[ "$name" == "$current" ]]; then
			suffix=' (current)'
		fi
		printf '%s%s\t%s\n' "$display" "$suffix" "$name"
	done < <(theme_list)
}

theme_pick() {
	local selected current header

	if ! command -v fzf >/dev/null 2>&1; then
		printf 'fzf is required for theme_pick\n' >&2
		return 1
	fi

	current="$(theme_current_name 2>/dev/null || true)"
	header='Pick a theme'
	if [[ -n "$current" ]]; then
		header="current: $(theme_display_name "$current")"
	fi

	theme_source_fzf >/dev/null 2>&1 || FZF_THEME_ARGS=()
	selected="$(theme_picker_entries | fzf --border=rounded --info=right --prompt='theme> ' --delimiter=$'\t' --with-nth=1 --header "$header" "${FZF_THEME_ARGS[@]}")" || return 1
	[[ -n "$selected" ]] || return 1

	theme_apply "${selected##*$'\t'}"
}

theme_ensure_shell_files() {
	if [[ -f "$THEME_ENV_FILE" && -f "$THEME_FZF_FILE" ]]; then
		return 0
	fi

	theme_load_current || return 1
	theme_write_shell_files
}

theme_print_list() {
	local name

	while IFS= read -r name; do
		printf '%s\t%s\n' "$name" "$(theme_display_name "$name")"
	done < <(theme_list)
}

theme_usage() {
	cat <<EOF
Usage: ${BASH_SOURCE[0]} [command] [theme]

Commands:
  pick            Pick a theme with fzf (default)
  apply [theme]   Apply a named theme or the current one
  set <theme>     Alias for apply <theme>
  list            List theme ids and display names
  current         Print the current theme id
  env             Regenerate current_theme.env and current_fzf.sh
EOF
}

theme_main() {
	local command="${1:-pick}"

	case "$command" in
	pick)
		theme_pick
		;;
	apply)
		if [[ -n "${2:-}" ]]; then
			theme_apply "$2"
		else
			theme_apply_current
		fi
		;;
	set)
		[[ -n "${2:-}" ]] || {
			printf 'theme name is required for set\n' >&2
			return 1
		}
		theme_apply "$2"
		;;
	list)
		theme_print_list
		;;
	current)
		theme_current_name
		;;
	env)
		theme_load_current || return 1
		theme_write_shell_files
		;;
	-h | --help | help)
		theme_usage
		;;
	*)
		printf 'Unknown command: %s\n' "$command" >&2
		theme_usage >&2
		return 1
		;;
	esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	theme_main "$@"
fi
