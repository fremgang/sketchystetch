#!/bin/bash

# calendar.sh - Display a popup calendar when clicking the datetime item
# Location: ~/.config/sketchybar/plugins/calendar.sh

POPUP_ID="calendar_popup"

# Check if popup is already showing and toggle
if sketchybar --query "$POPUP_ID" 2>/dev/null | grep -q "drawing=on"; then
  sketchybar --set "$POPUP_ID" drawing=off
  exit 0
fi

# Get current month and highlight
CURRENT_MONTH=$(date +"%B %Y")
CURRENT_DAY=$(date +"%d")
TODAY_STYLE="\033[7m" # Inverted text for today
RESET_STYLE="\033[0m"  # Reset formatting

# Generate styled calendar
CALENDAR=$(cal | sed "1s/^/${CURRENT_MONTH}\n/; s/ ${CURRENT_DAY} /${TODAY_STYLE}${CURRENT_DAY}${RESET_STYLE}/")

# Create popup background with formatted calendar
sketchybar --add item "$POPUP_ID" popup.datetime \
           --set "$POPUP_ID" \
                icon="$CALENDAR" \
                icon.font="SF Mono:Medium:12.0" \
                icon.padding_left=10 \
                icon.padding_right=10 \
                background.color=0xee111111 \
                background.corner_radius=5 \
                background.border_width=1 \
                background.border_color=0xff333333 \
                background.drawing=on \
                drawing=on \
                popup.align=center