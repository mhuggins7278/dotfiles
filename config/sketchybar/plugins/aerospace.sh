#!/usr/bin/env bash

# Always query aerospace directly for the current focused workspace
# Use full path since sketchybar may not have homebrew in PATH
WORKSPACE=$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null)

# Update the SketchyBar item with the current workspace
sketchybar --set aerospace icon="$WORKSPACE"
