#!/bin/bash

# Extract the left channel volume (in %)
left=$(pactl get-sink-volume @DEFAULT_SINK@ | awk -F'/' 'NR==1{print $2}' | tr -d ' %')

# Extract the right channel volume (in %)
right=$(pactl get-sink-volume @DEFAULT_SINK@ | awk -F'/' 'NR==1{print $4}' | tr -d ' %')

# Take the higher of the two (to be safe when incrementing)
current=$((left > right ? left : right))

# Add 5
new=$((current + 5))

# Cap at 100
if [ "$new" -gt 100 ]; then
    new=100
fi

# Apply to both channels equally
pactl set-sink-volume @DEFAULT_SINK@ ${new}%
