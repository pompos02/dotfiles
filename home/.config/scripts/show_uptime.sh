#!/bin/bash

# Get the uptime in a "pretty" format
UPTIME_PRETTY=$(uptime -p)

# Extract days, hours, and minutes separately
DAYS=$(echo "$UPTIME_PRETTY" | grep -o '[0-9]\+ day' | grep -o '[0-9]\+')
HOURS=$(echo "$UPTIME_PRETTY" | grep -o '[0-9]\+ hour' | grep -o '[0-9]\+')
MINUTES=$(echo "$UPTIME_PRETTY" | grep -o '[0-9]\+ minute' | grep -o '[0-9]\+')

# Default to 0 if not found
DAYS=${DAYS:-0}
HOURS=${HOURS:-0}
MINUTES=${MINUTES:-0}

# Convert total hours = (days * 24) + hours
TOTAL_HOURS=$((DAYS * 24 + HOURS))

# Format minutes with a leading zero
FORMATTED_MINUTES=$(printf "%02d" "$MINUTES")

echo "up:($TOTAL_HOURS:$FORMATTED_MINUTES)"
