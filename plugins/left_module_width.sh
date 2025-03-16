#!/bin/bash

# Get all items in the left.spacer
ITEMS=$(sketchybar --query left.spacer | grep "associated_space" | grep -o '\[[^]]*\]' | tr -d '[]')
IFS=',' read -ra ITEM_ARRAY <<< "$ITEMS"

# Calculate total width
TOTAL_WIDTH=0
for ITEM in "${ITEM_ARRAY[@]}"; do
  ITEM_WIDTH=$(sketchybar --query "$ITEM" | grep -o "width : [0-9]*" | awk '{print $3}')
  PADDING_L=$(sketchybar --query "$ITEM" | grep -o "padding_left : [0-9]*" | awk '{print $3}')
  PADDING_R=$(sketchybar --query "$ITEM" | grep -o "padding_right : [0-9]*" | awk '{print $3}')
  TOTAL_WIDTH=$((TOTAL_WIDTH + ITEM_WIDTH + PADDING_L + PADDING_R))
done

# Add left and right padding of the spacer itself
SPACER_PADDING_L=$(sketchybar --query left.spacer | grep -o "padding_left : [0-9]*" | awk '{print $3}')
SPACER_PADDING_R=$(sketchybar --query left.spacer | grep -o "padding_right : [0-9]*" | awk '{print $3}')
TOTAL_WIDTH=$((TOTAL_WIDTH + SPACER_PADDING_L + SPACER_PADDING_R))

# Update the spacer width
sketchybar --set left.spacer width=$TOTAL_WIDTH
