#!/bin/bash

# Format time as "01:34"
TIME=$(date +"%H:%M")

# Set the time
sketchybar --set $NAME label="$TIME"