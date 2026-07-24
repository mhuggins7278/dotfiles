#!/usr/bin/env bash

SKETCHYBAR="/opt/homebrew/bin/sketchybar"
BATTERY_INFO=$(/usr/bin/pmset -g batt)

if [[ $BATTERY_INFO =~ ([0-9]+)% ]]; then
  PERCENTAGE="${BASH_REMATCH[1]}"
else
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON=""
  ;;
  [6-8][0-9]) ICON=""
  ;;
  [3-5][0-9]) ICON=""
  ;;
  [1-2][0-9]) ICON=""
  ;;
  *) ICON=""
esac

if [[ $BATTERY_INFO == *"AC Power"* ]]; then
  ICON=""
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
"$SKETCHYBAR" --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
