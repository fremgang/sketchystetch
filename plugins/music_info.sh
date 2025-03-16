#!/bin/bash

# Check if Music is running
if ! pgrep -x "Music" >/dev/null; then
  sketchybar --set music.info drawing=off
  exit 0
fi

# Check if music is playing or paused
STATE=$(osascript -e 'tell application "Music" to player state as string')
if [[ "$STATE" != "playing" && "$STATE" != "paused" ]]; then
  sketchybar --set music.info drawing=off
  exit 0
fi

# Get track info
TRACK=$(osascript -e 'tell application "Music" to name of current track')
ARTIST=$(osascript -e 'tell application "Music" to artist of current track')

# Format track info
if [[ ${#TRACK} -gt 30 ]]; then
  TRACK="${TRACK:0:27}..."
fi

if [[ ${#ARTIST} -gt 18 ]]; then
  ARTIST="${ARTIST:0:15}..."
fi

# Update label - just show track and artist info, no controls
LABEL="$TRACK — $ARTIST"
sketchybar --set music.info label="$LABEL" drawing=on
