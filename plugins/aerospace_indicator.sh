#!/bin/bash

SPACE_ID="$1"
ITEM_NAME="$2"

# Get current space from event or query directly
CURRENT_SPACE="$SPACE"
if [ -z "$CURRENT_SPACE" ]; then
  CURRENT_SPACE=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
fi

# Update indicator appearance with refined active state
if [[ "$CURRENT_SPACE" == "$SPACE_ID" ]]; then
  # Active workspace - solid background
  sketchybar --set "$ITEM_NAME" \
    background.drawing=on \
    background.color=0x60404040 \
    label.color=0xffdddddd
else
  # Inactive workspace
  sketchybar --set "$ITEM_NAME" \
    background.drawing=off \
    label.color=0xffa0a0a0
fi

# Update the parent spacer width
"$HOME/.config/sketchybar/plugins/left_module_width.sh"
