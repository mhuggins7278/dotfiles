-- Folder Action: move-vtt-to-zoom-transcripts
-- Attached to ~/Downloads/
-- Moves any .vtt file that lands in Downloads to ~/zoom-transcripts/
-- so the launchd transcript watcher can pick it up without TCC restrictions.

on adding folder items to this_folder after receiving these_items
    set dest_folder to ((path to home folder as text) & "zoom-transcripts:")
    repeat with this_item in these_items
        try
            set item_name to name of (info for this_item)
            if item_name ends with ".vtt" then
                tell application "Finder"
                    move this_item to folder dest_folder
                end tell
            end if
        on error errMsg
            -- silently skip items that can't be moved
        end try
    end repeat
end
