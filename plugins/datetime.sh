#!/bin/bash

# Format date and time
TIME=$(date +"%H:%M")
DATE=$(date +"%a %d")

# Combined display
DATETIME="$TIME · $DATE"

# Set the label
sketchybar --set datetime label="$DATETIME"
