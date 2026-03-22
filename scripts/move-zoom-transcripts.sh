#!/bin/zsh
# move-zoom-transcripts.sh
# Triggered by WatchPaths on ~/Downloads/.
# Uses mdfind (Spotlight) to enumerate .vtt files without needing Full Disk Access,
# then moves them to ~/zoom-transcripts/ for the launchd transcript watcher.

WATCH_DIR="$HOME/Downloads"
DEST_DIR="$HOME/zoom-transcripts"
LOG="/tmp/zoom-mover.log"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

echo "[$(date)] mover triggered" >> "$LOG"

# Wait briefly for the file to fully land (WatchPaths fires on dir entry change,
# which can precede the file being visible to Spotlight). Retry up to 6 times.
vtt_files=()
for attempt in {1..6}; do
  # Use global mdfind (no -onlyin) to bypass TCC restrictions on ~/Downloads
  # in launchd context, then filter to only files under WATCH_DIR.
  local mdfind_out
  mdfind_out=$(mdfind "kMDItemFSName == '*.vtt'" 2>/dev/null | grep "^${WATCH_DIR}/")
  if [[ -n "$mdfind_out" ]]; then
    vtt_files=("${(@f)mdfind_out}")
  fi
  echo "[$(date)] attempt $attempt: found ${#vtt_files[@]} vtt files" >> "$LOG"
  [[ ${#vtt_files[@]} -gt 0 ]] && break
  sleep 3
done

if [[ ${#vtt_files[@]} -eq 0 ]]; then
  echo "[$(date)] no vtt files found, exiting" >> "$LOG"
  exit 0
fi

for vtt in "${vtt_files[@]}"; do
  filename="$(basename "$vtt")"
  echo "[$(date)] moving $filename -> $DEST_DIR/" >> "$LOG"
  mv "$vtt" "$DEST_DIR/" && echo "[$(date)] moved $filename" >> "$LOG" \
    || echo "[$(date)] FAILED to move $filename" >> "$LOG"
done
