#!/usr/bin/env s

tty_path="$1"
[ -n "$tty_path" ] || exit 0

ssh_cmd="$(ps -o args= -t "$tty_path" 2>/dev/null | grep -m1 '^ssh ' )"
[ -n "$ssh_cmd" ] || exit 0

set -- "$ssh_cmd"
shift

while [ $# -gt 0 ]; do
  case "$1" in
    --)
      shift
      break
      ;;
    -b|-c|-D|-E|-e|-F|-I|-i|-J|-L|-l|-m|-O|-o|-p|-Q|-R|-S|-W|-w)
      [ $# -ge 2 ] || exit 0
      shift 2
      ;;
    -*)
      shift
      ;;
    *)
      break
      ;;
  esac
done

host="$1"

[ -n "$host" ] || exit 0
host="${host#*@}"
host="${host%%:*}"
[ -n "$host" ] || exit 0

printf '@%s ' "$host"
