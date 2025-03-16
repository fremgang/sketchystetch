#!/bin/bash

# Get the front app name
FRONT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

# Limit to a reasonable length
if [[ ${#FRONT_APP} -gt 25 ]]; then
  FRONT_APP="${FRONT_APP:0:22}..."
fi

# Update the label with the app name
sketchybar --set front_app label="$FRONT_APP"
