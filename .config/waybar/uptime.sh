#!/bin/bash

# Get the uptime in a "pretty" format
UPTIME_PRETTY=$(uptime -p)

# Extract hours and minutes using sed
# This assumes the format "up X days, Y hours, Z minutes" or "up X hours, Y minutes" etc.
# We're specifically looking for "X hours" and "Y minutes"
HOURS=$(echo "$UPTIME_PRETTY" | sed -n 's/.* \([0-9]\+\) hour[s]\?, \([0-9]\+\) minute[s]\?.*/\1/p')
MINUTES=$(echo "$UPTIME_PRETTY" | sed -n 's/.* \([0-9]\+\) hour[s]\?, \([0-9]\+\) minute[s]\?.*/\2/p')

# Handle cases where only minutes are present (uptime < 1 hour)
if [ -z "$HOURS" ] && [ -n "$MINUTES" ]; then
    HOURS=0
elif [ -z "$HOURS" ] && [ -z "$MINUTES" ]; then
    # Handle cases where uptime is less than 1 minute (e.g., "up 1 minute")
    # This sed command captures only minutes if hours are not present
    MINUTES=$(echo "$UPTIME_PRETTY" | sed -n 's/.* \([0-9]\+\) minute[s]\?.*/\1/p')
    HOURS=0
fi

# Ensure hours and minutes are defined, default to 0 if not found
HOURS=${HOURS:-0}
MINUTES=${MINUTES:-0}

# Format minutes with a leading zero if less than 10
FORMATTED_MINUTES=$(printf "%02d" "$MINUTES")

echo "up:($HOURS:$FORMATTED_MINUTES)"
