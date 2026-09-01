#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
THEME_SCRIPT="${SCRIPT_DIR}/../theme/theme.sh"

if [[ $# -eq 0 ]]; then
	set -- pick
fi

exec "$THEME_SCRIPT" "$@"
