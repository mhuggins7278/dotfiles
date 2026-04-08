#!/bin/zsh
# process-zoom-transcript.sh
# Watches ~/Downloads/zoom-transcripts/ for .vtt files dropped from Zoom,
# passes each to the opencode daily-notes agent for summarization and note creation,
# then deletes the processed file.

WATCH_DIR="$HOME/zoom-transcripts"
PROCESSED_DIR="$HOME/zoom-transcripts/processed"
LOG="/tmp/zoom-transcript.log"
DEBUG_LOG="/tmp/zoom-transcript-debug.log"

# Ensure homebrew bins are available (launchd login shell omits /opt/homebrew/bin)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

mkdir -p "$PROCESSED_DIR"

echo "[$(date)] script started, HOME=$HOME, PATH=$PATH" >> "$DEBUG_LOG"

# Wait briefly for the file to fully land (WatchPaths fires on dir entry change,
# which can precede the file being visible to a glob). Retry up to 5 times.
vtt_files=()
for attempt in {1..5}; do
  vtt_files=("$WATCH_DIR"/*.vtt(N))
  echo "[$(date)] attempt $attempt: found ${#vtt_files[@]} files in $WATCH_DIR" >> "$DEBUG_LOG"
  [[ ${#vtt_files[@]} -gt 0 ]] && break
  sleep 2
done

if [[ ${#vtt_files[@]} -eq 0 ]]; then
  echo "[$(date)] exiting: no vtt files found after retries" >> "$DEBUG_LOG"
  exit 0
fi

for vtt in "${vtt_files[@]}"; do
  echo "[$(date)] Processing: $(basename "$vtt")" >> "$LOG"

  opencode run \
    --agent daily-notes \
    "Process the attached Zoom meeting transcript. Infer the meeting title from the content. Create a meeting note following the Meeting Transcripts workflow, add a backlink in today's daily note, and route any action items to the correct sections." \
    -f "$vtt" \
    >> "$LOG" 2>&1

  if [[ $? -eq 0 ]]; then
    mv "$vtt" "$PROCESSED_DIR/"
    osascript -e 'display notification "Meeting notes created" with title "Zoom Transcript"'
    echo "[$(date)] Done: $(basename "$vtt")" >> "$LOG"
  else
    osascript -e 'display notification "Failed to process transcript — check /tmp/zoom-transcript.log" with title "Zoom Transcript Error"'
    echo "[$(date)] FAILED: $(basename "$vtt")" >> "$LOG"
  fi
done
