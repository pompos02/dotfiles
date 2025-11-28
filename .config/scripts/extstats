#!/bin/bash

dir="${1:-.}"

  # detect terminal for color
if [ -t 1 ]; then color=1; else color=0; fi
  find "$dir" -type f -name '*.*' -print |
      awk '
    {
        file = $0

        # Extract extension from last dot
        pos = match(file, /\.[^.]+$/)
        if (pos == 0)
            next   # skip files with no extension

            ext = substr(file, pos + 1)

        # Skip weird cases: empty extension or only dots
        if (ext == "" || ext ~ /^[.]+$/)
            next

        # Count files
        count[ext]++

        # Get lines + bytes
        cmd = "wc -lc < \"" file "\""
        cmd | getline res
        close(cmd)

        split(res, tmp)
        lines = tmp[1]
        bytes = tmp[2]

        total_lines[ext] += lines
        total_bytes[ext] += bytes
    }
    END {
        for (e in count)
            printf "%s\t%d\t%d\t%d\n", e, count[e], total_lines[e], total_bytes[e]
        }' |
    sort -k2,2nr |
    awk -v color="$color" '
    BEGIN {
        if (color) {
            CYAN="\033[36m"; GREEN="\033[32m"; YELLOW="\033[33m"
            MAGENTA="\033[35m"; RESET="\033[0m"
        } else {
            CYAN=GREEN=YELLOW=MAGENTA=RESET=""
        }

    printf CYAN "%-10s %10s %12s %12s %12s %12s %12s\n",
    "EXT", "FILES", "LINES", "BYTES", "SIZE", "AVG_LINES", "AVG_SIZE"
    printf "---------------------------------------------------------------------------------------------\n" RESET
}

function hr(bytes,    units,i) {
    split("B KB MB GB TB", units)
    for (i=1; bytes>=1024 && i<5; i++) bytes/=1024
        return sprintf("%.1f %s", bytes, units[i])
    }

{
    ext=$1; files=$2; lines=$3; bytes=$4
    size=hr(bytes)
    avg_lines=(files>0?lines/files:0)
    avg_size=hr((files>0?bytes/files:0))

    printf GREEN "%-10s" RESET " ", ext
    printf YELLOW "%10d" RESET " %12d %12d ", files, lines, bytes
    printf MAGENTA "%12s %12.1f %12s" RESET "\n", size, avg_lines, avg_size
}'
