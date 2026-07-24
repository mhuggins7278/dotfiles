#!/usr/bin/env bash

SKETCHYBAR="/opt/homebrew/bin/sketchybar"

# Always query aerospace directly for the current focused workspace
# Use full path since sketchybar may not have homebrew in PATH
WORKSPACE=$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null)

# Update the SketchyBar item with the current workspace
"$SKETCHYBAR" --set aerospace icon="$WORKSPACE"
