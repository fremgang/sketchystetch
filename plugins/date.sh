#!/bin/bash

# Format date as "Sun 16"
DATE=$(date +"%a %d")

# Set the date
sketchybar --set $NAME label="$DATE"