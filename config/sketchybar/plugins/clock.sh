#!/bin/sh

SKETCHYBAR="/opt/homebrew/bin/sketchybar"

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

LOCAL_TIME=$(/bin/date '+%m-%d %I:%M%p')
IRELAND_TIME=$(TZ=Europe/Dublin /bin/date '+%H:%M')
"$SKETCHYBAR" --set "$NAME" label="$LOCAL_TIME [$IRELAND_TIME IST]"
