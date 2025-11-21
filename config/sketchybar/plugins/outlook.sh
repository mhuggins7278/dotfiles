#!/usr/bin/env bash

# Get next meeting from Calendar app (syncs with Outlook)
MEETING_INFO=$(osascript <<EOF
tell application "Calendar"
    set now to current date
    set tomorrowEnd to now + (48 * 60 * 60)
    
    set nextMeeting to ""
    set nextMeetingTime to tomorrowEnd
    set nextMeetingFound to false
    
    try
        -- Get all upcoming events from all calendars (today and tomorrow)
        repeat with aCalendar in (every calendar)
            set upcomingEvents to (every event of aCalendar whose start date ≥ now and start date < tomorrowEnd)
            
            repeat with anEvent in upcomingEvents
                set eventStart to start date of anEvent
                if eventStart < nextMeetingTime then
                    set nextMeetingTime to eventStart
                    set eventSummary to summary of anEvent
                    set eventTime to time string of eventStart
                    set eventDate to date string of eventStart
                    set todayDate to date string of now
                    
                    -- Check if it's today or tomorrow
                    if eventDate is equal to todayDate then
                        set nextMeeting to eventSummary & "|" & eventTime & "|TODAY"
                    else
                        set nextMeeting to eventSummary & "|" & eventTime & "|TOMORROW"
                    end if
                    set nextMeetingFound to true
                end if
            end repeat
        end repeat
        
        if nextMeetingFound then
            return nextMeeting
        else
            return "NO_MEETINGS"
        end if
    on error errMsg
        return "ERROR: " & errMsg
    end try
end tell
EOF
)

# Parse the result
if [[ "$MEETING_INFO" == "NO_MEETINGS" ]]; then
  sketchybar --set outlook drawing=off
elif [[ "$MEETING_INFO" == ERROR* ]]; then
  sketchybar --set outlook drawing=on icon="📅" label="Error"
else
  # Split subject, time, and day
  SUBJECT=$(echo "$MEETING_INFO" | cut -d'|' -f1)
  TIME=$(echo "$MEETING_INFO" | cut -d'|' -f2 | sed 's/:00 / /g')
  DAY=$(echo "$MEETING_INFO" | cut -d'|' -f3)
  
  # Truncate subject if too long
  if [ ${#SUBJECT} -gt 25 ]; then
    SUBJECT="${SUBJECT:0:22}..."
  fi
  
  # Format display
  if [[ "$DAY" == "TODAY" ]]; then
    sketchybar --set outlook drawing=on icon="📅" label="$TIME: $SUBJECT"
  else
    sketchybar --set outlook drawing=on icon="📅" label="Tomorrow $TIME: $SUBJECT"
  fi
fi
