#!/bin/sh

# Get Spotify status using AppleScript
if ! pgrep -x "Spotify" > /dev/null; then
  sketchybar --set "$NAME" label="" icon=""
  exit 0
fi

PLAYER_STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [ "$PLAYER_STATE" = "playing" ]; then
  TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
  ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
  
  # Truncate if too long
  MAX_LENGTH=30
  DISPLAY="$ARTIST - $TRACK"
  if [ ${#DISPLAY} -gt $MAX_LENGTH ]; then
    DISPLAY="${DISPLAY:0:$MAX_LENGTH}..."
  fi
  
  sketchybar --set "$NAME" label="$DISPLAY" icon="󰓇"
elif [ "$PLAYER_STATE" = "paused" ]; then
  TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
  ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
  
  MAX_LENGTH=30
  DISPLAY="$ARTIST - $TRACK"
  if [ ${#DISPLAY} -gt $MAX_LENGTH ]; then
    DISPLAY="${DISPLAY:0:$MAX_LENGTH}..."
  fi
  
  sketchybar --set "$NAME" label="$DISPLAY" icon="󰏤"
else
  sketchybar --set "$NAME" label="" icon=""
fi
