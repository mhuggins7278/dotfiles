#!/usr/bin/env bash

SKETCHYBAR="/opt/homebrew/bin/sketchybar"
RED="0xfff38ba8"
YELLOW="0xfff9e2af"
TEXT="0xffcdd6f4"

TOTAL_MEM=$(/usr/sbin/sysctl -n hw.memsize)
read -r PAGE_SIZE FREE_PAGES INACTIVE_PAGES < <(
  /usr/bin/vm_stat | /usr/bin/awk '
    /page size of [0-9]+ bytes/ {
      for (field = 1; field <= NF; field++) {
        if ($field == "of") {
          page_size = $(field + 1)
          break
        }
      }
    }
    /Pages free:/ { free_pages = $3; sub(/\.$/, "", free_pages) }
    /Pages inactive:/ { inactive_pages = $3; sub(/\.$/, "", inactive_pages) }
    END { print page_size, free_pages, inactive_pages }
  '
)

if ! [[ "$TOTAL_MEM" =~ ^[0-9]+$ && "$PAGE_SIZE" =~ ^[0-9]+$ && \
  "$FREE_PAGES" =~ ^[0-9]+$ && "$INACTIVE_PAGES" =~ ^[0-9]+$ ]]; then
  exit 0
fi

FREE_BYTES=$(( (FREE_PAGES + INACTIVE_PAGES) * PAGE_SIZE ))
FREE_TENTHS=$(( FREE_BYTES * 10 / 1024 / 1024 / 1024 ))
USED_PERCENT=$(( (TOTAL_MEM - FREE_BYTES) * 100 / TOTAL_MEM ))

if (( USED_PERCENT >= 90 )); then
  ICON="󰍛"
  COLOR="$RED"
elif (( USED_PERCENT >= 70 )); then
  ICON="󰍛"
  COLOR="$YELLOW"
else
  ICON="󰍛"
  COLOR="$TEXT"
fi

"$SKETCHYBAR" --set memory \
  icon="$ICON" \
  label="$((FREE_TENTHS / 10)).$((FREE_TENTHS % 10))GB free" \
  icon.color="$COLOR"
