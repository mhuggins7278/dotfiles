#!/usr/bin/env bash

# Get the current focused workspace from AeroSpace
WORKSPACE=$(aerospace list-workspaces --focused)

# Update the SketchyBar item with the current workspace
sketchybar --set aerospace icon="$WORKSPACE"
