#!/bin/bash

# Get all items in the right.spacer
ITEMS=$(sketchybar --query right.spacer | grep "associated_space" | grep -o '\[[^]]*\]' | tr -d '[]')
IFS=',' read -ra ITEM_ARRAY <<< "$ITEMS"

# Calculate total width
TOTAL_WIDTH=0
for ITEM in "${ITEM_ARRAY[@]}"; do
  ITEM_WIDTH=$(sketchybar --query "$ITEM" | grep -o "width : [0-9]*" | awk '{print $3}')
  PADDING_L=$(sketchybar --query "$ITEM" | grep -o "padding_left : [0-9]*" | awk '{print $3}')
  PADDING_R=$(sketchybar --query "$ITEM" | grep -o "padding_right : [0-9]*" | awk '{print $3}')
  TOTAL_WIDTH=$((TOTAL_WIDTH + ITEM_WIDTH + PADDING_L + PADDING_R))
done

# Add padding of the spacer itself
SPACER_PADDING_L=$(sketchybar --query right.spacer | grep -o "padding_left : [0-9]*" | awk '{print $3}')
SPACER_PADDING_R=$(sketchybar --query right.spacer | grep -o "padding_right : [0-9]*" | awk '{print $3}')
TOTAL_WIDTH=$((TOTAL_WIDTH + SPACER_PADDING_L + SPACER_PADDING_R))

# Update the spacer width
sketchybar --set right.spacer width=$TOTAL_WIDTH
