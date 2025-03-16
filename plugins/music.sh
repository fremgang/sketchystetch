#!/bin/bash

# music.sh - Display current track and album art
# Location: ~/.config/sketchybar/plugins/music.sh

MUSIC_DIR="/tmp/sketchybar_cache/music"
ART_FILE="$MUSIC_DIR/current_artwork.jpg"

# Create cache directory
mkdir -p "$MUSIC_DIR"

# Check if Music is running
if ! pgrep -x "Music" >/dev/null; then
  sketchybar -m --set music.title drawing=off
  sketchybar -m --set music.album drawing=off
  exit 0
fi

# Get music info with single osascript call for efficiency
MUSIC_INFO=$(osascript -e '
tell application "Music"
  if player state is playing or player state is paused then
    set track_name to name of current track
    set artist_name to artist of current track
    set album_name to album of current track
    set player_state to player state as text
    return track_name & "|" & artist_name & "|" & album_name & "|" & player_state
  else
    return "none"
  end if
end tell
')

# Exit if not playing
if [[ "$MUSIC_INFO" == "none" ]]; then
  sketchybar -m --set music.title drawing=off
  sketchybar -m --set music.album drawing=off
  exit 0
fi

# Parse music info
IFS='|' read -r TRACK ARTIST ALBUM STATE <<< "$MUSIC_INFO"

# Truncate long names
if [[ ${#TRACK} -gt 25 ]]; then
  TRACK="${TRACK:0:22}..."
fi

if [[ ${#ARTIST} -gt 15 ]]; then
  ARTIST="${ARTIST:0:12}..."
fi

# Format label
MUSIC_LABEL="$TRACK — $ARTIST"

# Update track info
sketchybar -m --set music.title label="$MUSIC_LABEL" drawing=on

# Extract album art
osascript -e "
tell application \"Music\"
  tell artwork 1 of current track
    set artData to raw data
    set artFile to \"$ART_FILE\"
    
    set fileRef to open for access file artFile with write permission
    set eof of fileRef to 0
    write artData to fileRef
    close access fileRef
  end tell
end tell
" 2>/dev/null

# Check if art file exists and is valid
if [[ -s "$ART_FILE" ]]; then
  sketchybar -m --set music.album background.image="$ART_FILE" background.drawing=on drawing=on
else
  # Use a music icon as fallback
  sketchybar -m --set music.album background.drawing=off icon=􀑪 icon.drawing=on drawing=on
fi