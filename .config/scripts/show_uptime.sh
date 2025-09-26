#!/bin/bash

# Get the uptime in a "pretty" format
UPTIME_PRETTY=$(uptime -p)

# Extract days, hours, and minutes separately
DAYS=$(echo "$UPTIME_PRETTY" | sed -n 's/.*\([0-9]\+\) day[s]\?.*/\1/p')
HOURS=$(echo "$UPTIME_PRETTY" | sed -n 's/.*\([0-9]\+\) hour[s]\?.*/\1/p')
MINUTES=$(echo "$UPTIME_PRETTY" | sed -n 's/.*\([0-9]\+\) minute[s]\?.*/\1/p')

# Default to 0 if not found
DAYS=${DAYS:-0}
HOURS=${HOURS:-0}
MINUTES=${MINUTES:-0}

# Convert total hours = (days * 24) + hours
TOTAL_HOURS=$((DAYS * 24 + HOURS))

# Format minutes with a leading zero
FORMATTED_MINUTES=$(printf "%02d" "$MINUTES")

echo "up:($TOTAL_HOURS:$FORMATTED_MINUTES)"
