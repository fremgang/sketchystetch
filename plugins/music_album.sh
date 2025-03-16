#!/bin/bash

# Music album art with BTT-inspired approach

# Check if Music is running
if ! osascript -e 'tell application "System Events" to (name of processes) contains "Music"' | grep "true" &>/dev/null; then
  exit 0
fi

# Create temporary directory if it doesn't exist
TMP_DIR="/tmp/sketchybar_album_art"
mkdir -p "$TMP_DIR"
ART_FILE="$TMP_DIR/current_artwork.jpg"

# Use BTT-style approach for album art
osascript <<EOF
tell application "System Events"
  set num to count (every process whose name is "Music")
end tell

if num > 0 then
  tell application "Music" 
    if player state is playing or player state is paused then
      try
        tell artwork 1 of current track
          set srcBytes to raw data
          -- figure out the proper file extension
          if format is «class PNG » then
            set ext to ".png"
          else
            set ext to ".jpg"
          end if
        end tell
        
        set fileName to "$ART_FILE"
        -- write to file
        set outFile to open for access file fileName with write permission
        -- truncate the file
        set eof outFile to 0
        -- write the image bytes to the file
        write srcBytes to outFile
        close access outFile
        return "true"
      on error errMsg
        return "false: " & errMsg
      end try
    end if
  end tell
end if
return "false"
