#!/bin/bash

# Check if Music is running
if ! osascript -e 'tell application "System Events" to (name of processes) contains "Music"' | grep "true" &>/dev/null; then
  exit 0
fi

# Get music info
TRACK=$(osascript -e 'tell application "Music" to name of current track')
ARTIST=$(osascript -e 'tell application "Music" to artist of current track')

if [[ -n "$TRACK" && -n "$ARTIST" ]]; then
  # Careful truncation to maintain visual balance
  if [[ ${#TRACK} -gt 20 ]]; then
    TRACK="${TRACK:0:17}..."
  fi
  
  if [[ ${#ARTIST} -gt 18 ]]; then
    ARTIST="${ARTIST:0:15}..."
  fi
  
  # Clean typographic presentation
  LABEL="$TRACK — $ARTIST"
  sketchybar --set $NAME label="$LABEL"
else
  sketchybar --set $NAME label="Not Playing"
fi

# Update center module width
"$HOME/.config/sketchybar/plugins/center_module_width.sh"
