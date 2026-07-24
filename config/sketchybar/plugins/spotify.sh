#!/usr/bin/env bash

SKETCHYBAR="/opt/homebrew/bin/sketchybar"
SEPARATOR=$'\037'

if ! /usr/bin/pgrep -x "Spotify" > /dev/null; then
  "$SKETCHYBAR" --set "$NAME" label="" icon=""
  exit 0
fi

PLAYER_INFO=$(/usr/bin/osascript 2>/dev/null <<'EOF'
with timeout of 4 seconds
  tell application "Spotify"
    set playerState to player state as text
    if playerState is "playing" or playerState is "paused" then
      set currentTrack to current track
      return playerState & (ASCII character 31) & artist of currentTrack & (ASCII character 31) & name of currentTrack
    end if
    return playerState
  end tell
end timeout
EOF
)

IFS="$SEPARATOR" read -r PLAYER_STATE ARTIST TRACK <<< "$PLAYER_INFO"

if [[ "$PLAYER_STATE" = "playing" || "$PLAYER_STATE" = "paused" ]]; then
  MAX_LENGTH=30
  DISPLAY="$ARTIST - $TRACK"
  if (( ${#DISPLAY} > MAX_LENGTH )); then
    DISPLAY="${DISPLAY:0:$MAX_LENGTH}..."
  fi
  if [[ "$PLAYER_STATE" = "playing" ]]; then
    "$SKETCHYBAR" --set "$NAME" label="$DISPLAY" icon="󰓇"
  else
    "$SKETCHYBAR" --set "$NAME" label="$DISPLAY" icon="󰏤"
  fi
else
  "$SKETCHYBAR" --set "$NAME" label="" icon=""
fi
