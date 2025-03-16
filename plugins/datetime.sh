#!/bin/bash

# datetime.sh - Show date and time
# Location: ~/.config/sketchybar/plugins/datetime.sh

# Format date and time
TIME=$(date +"%H:%M")
DATE=$(date +"%a %d")

# Combined display
DATETIME="$TIME · $DATE"

# Set the label
sketchybar -m --set datetime label="$DATETIME"