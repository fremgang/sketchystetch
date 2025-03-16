#!/bin/bash

# trackpad_gestures.sh - Handle trackpad gestures for workspace switching
# Location: ~/.config/sketchybar/plugins/trackpad_gestures.sh

# Check arguments
direction="$1"
[ -z "$direction" ] && exit 1

# Get current workspace info
current=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
max_workspace=$(aerospace list-workspaces --all 2>/dev/null | wc -w | tr -d ' ')
[ -z "$max_workspace" ] && max_workspace=9

# Calculate target workspace based on swipe direction
case "$direction" in
  "left")
    # Swipe left = next workspace
    new_workspace=$((current + 1))
    [ "$new_workspace" -gt "$max_workspace" ] && new_workspace=1
    ;;
  "right")
    # Swipe right = previous workspace
    new_workspace=$((current - 1))
    [ "$new_workspace" -lt 1 ] && new_workspace="$max_workspace"
    ;;
  *)
    exit 1
    ;;
esac

# Direct update for minimal latency
aerospace workspace "$new_workspace"

# Direct label updates for workspaces - faster than recalculating
dots=""
for i in $(seq 1 $max_workspace); do
  if [ "$i" -eq "$new_workspace" ]; then
    dots="${dots}●"
  else
    dots="${dots}○"
  fi
  dots="${dots} "
done

sketchybar --set workspaces label="$dots"

# Also trigger the event for other subscribers
sketchybar --trigger aerospace_workspace_change space="$new_workspace"