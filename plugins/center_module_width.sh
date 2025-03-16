#!/bin/bash

# Check if music is playing
osascript -e 'tell application "System Events" to (name of processes) contains "Music"' | grep "true" &>/dev/null
if [ $? -ne 0 ]; then
  # No music playing, hide the center module
  sketchybar --set center.spacer width=0 drawing=off
  exit 0
fi

# Get all items in the center.spacer
ITEMS=$(sketchybar --query center.spacer | grep "associated_space" | grep -o '\[[^]]*\]' | tr -d '[]')
IFS=',' read -ra ITEM_ARRAY <<< "$ITEMS"

# Calculate total width
TOTAL_WIDTH=0
for ITEM in "${ITEM_ARRAY[@]}"; do
  # Only count visible items
  DRAWING=$(sketchybar --query "$ITEM" | grep -o "drawing : [a-z]*" | awk '{print $3}')
  if [ "$DRAWING" == "on" ]; then
    ITEM_WIDTH=$(sketchybar --query "$ITEM" | grep -o "width : [0-9]*" | awk '{print $3}')
    PADDING_L=$(sketchybar --query "$ITEM" | grep -o "padding_left : [0-9]*" | awk '{print $3}')
    PADDING_R=$(sketchybar --query "$ITEM" | grep -o "padding_right : [0-9]*" | awk '{print $3}')
    TOTAL_WIDTH=$((TOTAL_WIDTH + ITEM_WIDTH + PADDING_L + PADDING_R))
  fi
done

# Add padding of the spacer itself
SPACER_PADDING_L=$(sketchybar --query center.spacer | grep -o "padding_left : [0-9]*" | awk '{print $3}')
SPACER_PADDING_R=$(sketchybar --query center.spacer | grep -o "padding_right : [0-9]*" | awk '{print $3}')
TOTAL_WIDTH=$((TOTAL_WIDTH + SPACER_PADDING_L + SPACER_PADDING_R))

# Update the spacer width
if [ $TOTAL_WIDTH -gt 0 ]; then
  sketchybar --set center.spacer width=$TOTAL_WIDTH drawing=on
else
  sketchybar --set center.spacer width=0 drawing=off
fi
