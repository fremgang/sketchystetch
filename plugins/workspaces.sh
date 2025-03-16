#!/bin/bash

# Get current workspace
CURRENT=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null || echo "1 2 3 4 5")

# Build labels
LABEL=""
for ws in $WORKSPACES; do
  if [[ "$ws" == "$CURRENT" ]]; then
    LABEL+="●"
  else
    LABEL+="○"
  fi
  LABEL+=" "
done

# Set label
sketchybar --set workspaces label="$LABEL"
