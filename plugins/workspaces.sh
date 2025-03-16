#!/bin/bash

# workspaces.sh - Highly optimized workspace indicator with cached rendering
# Location: ~/.config/sketchybar/plugins/workspaces.sh

CACHE_DIR="/tmp/sketchybar_cache"
CACHE_FILE="$CACHE_DIR/workspaces"
LOCK_FILE="/tmp/sketchybar_locks/workspaces.lock"

# Use flock for thread safety
(
  flock -x 200
  
  # Get workspace info with fallback
  SPACE_ID="${space:-$FOCUSED_WORKSPACE}"
  
  if [ -z "$SPACE_ID" ]; then
    SPACE_ID=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
  fi
  
  # Get all workspace IDs
  WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null || echo "1 2 3 4 5")
  
  # Skip update if state hasn't changed
  workspace_state="$SPACE_ID:$WORKSPACES"
  if [ -f "$CACHE_FILE.state" ] && [ "$(cat "$CACHE_FILE.state")" = "$workspace_state" ]; then
    exit 0
  fi
  
  # Save state
  echo "$workspace_state" > "$CACHE_FILE.state"
  
  # Build dot indicator with precomputed strings for speed
  LABEL=""
  for ws in $WORKSPACES; do
    if [ "$ws" = "$SPACE_ID" ]; then
      LABEL+="●"
    else
      LABEL+="○"
    fi
    LABEL+=" "
  done
  
  # Cache and update
  echo "$LABEL" > "$CACHE_FILE"
  sketchybar --set workspaces label="$LABEL"
) 200>"$LOCK_FILE"