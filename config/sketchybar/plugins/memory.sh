#!/usr/bin/env bash

# Catppuccin Mocha colors
RED="0xfff38ba8"
YELLOW="0xfff9e2af"
TEXT="0xffcdd6f4"

# Get memory info in GB
TOTAL_MEM=$(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024}')
FREE_MEM=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
INACTIVE_MEM=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')

# Page size (usually 4096 bytes)
PAGE_SIZE=$(vm_stat | grep "page size" | awk '{print $8}')

# Calculate free memory in GB
FREE_GB=$(echo "scale=1; ($FREE_MEM + $INACTIVE_MEM) * $PAGE_SIZE / 1024 / 1024 / 1024" | bc)

# Calculate used memory
USED_GB=$(echo "scale=1; $TOTAL_MEM - $FREE_GB" | bc)

# Calculate percentage used
PERCENT_USED=$(echo "scale=0; ($USED_GB / $TOTAL_MEM) * 100" | bc)

# Choose icon based on memory usage
if [ "$PERCENT_USED" -ge 90 ]; then
  ICON="󰍛"  # Critical
  COLOR="$RED"
elif [ "$PERCENT_USED" -ge 70 ]; then
  ICON="󰍛"  # Warning
  COLOR="$YELLOW"
else
  ICON="󰍛"  # Normal
  COLOR="$TEXT"
fi

sketchybar --set memory icon="$ICON" label="${FREE_GB}GB free" icon.color="$COLOR"
