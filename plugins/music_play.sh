#!/bin/bash

# Check if Music is running
IS_RUNNING=$(osascript -e 'tell application "System Events" to (name of processes) contains "Music"')
if [[ "$IS_RUNNING" != "true" ]]; then
  sketchybar --set music.album drawing=off
  sketchybar --set music.title drawing=off
  sketchybar --set music.prev drawing=off
  sketchybar --set music.play drawing=off
  sketchybar --set music.next drawing=off
  sketchybar --set center.spacer drawing=off width=0
  exit 0
fi

# Check play state
IS_PLAYING=$(osascript -e 'tell application "Music" to player state as string')

# Update play/pause icon
if [[ "$IS_PLAYING" == "playing" ]]; then
  sketchybar --set $NAME icon="􀊆" icon.color=0xffb0b0b0
else
  sketchybar --set $NAME icon="􀊄" icon.color=0xffb0b0b0
fi

# Show/hide music controls
sketchybar --set music.album drawing=on
sketchybar --set music.title drawing=on
sketchybar --set music.prev drawing=on
sketchybar --set music.play drawing=on
sketchybar --set music.next drawing=on
sketchybar --set center.spacer drawing=on

# Update album art - with a small delay to ensure Music is ready
"$HOME/.config/sketchybar/plugins/music_album.sh"

# Trigger music_change event
sketchybar --trigger music_change
