#!/bin/bash

# Get window info from current workspace
windows=$(aerospace list-windows --workspace "$(aerospace list-workspaces --focused)" 2>/dev/null | grep -v "sketchybar")

# Extract and format app names
app_icons=""
num_apps=0

while IFS= read -r window; do
  app_name=$(echo "$window" | awk -F '|' '{print $2}' | xargs)
  
  # Get icon for this app
  icon_map "$app_name"
  if [ -n "$icon_result" ] && [ "$icon_result" != "default" ]; then
    app_icons+=" :$icon_result:"
    num_apps=$((num_apps + 1))
    
    # Limit to 5 icons max
    [ $num_apps -ge 5 ] && break
  fi
done <<< "$windows"

# Update sketchybar
if [ -n "$app_icons" ]; then
  sketchybar -m --set active_apps label="$app_icons" drawing=on
else
  sketchybar -m --set active_apps drawing=off
fi