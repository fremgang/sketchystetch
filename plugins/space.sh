#!/bin/bash

# space.sh - Handle workspace indicator appearance
# Location: ~/.config/sketchybar/plugins/space.sh

SPACE_ID="$1"
[ -z "$SPACE_ID" ] && exit 1

# Get current space from event or query directly
CURRENT_SPACE="${space:-$FOCUSED_WORKSPACE}"
if [ -z "$CURRENT_SPACE" ]; then
  # Try different methods to get current workspace
  CURRENT_SPACE=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
  
  # If aerospace fails, try yabai as fallback
  if [ "$CURRENT_SPACE" = "1" ] && command -v yabai >/dev/null; then
    CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index' 2>/dev/null || echo "1")
  fi
fi

# Check if workspace has windows
has_windows() {
  local ws="$1"
  local window_count=0
  
  if command -v aerospace >/dev/null; then
    window_count=$(aerospace list-windows --workspace "$ws" 2>/dev/null | wc -l | tr -d ' ')
  elif command -v yabai >/dev/null; then
    window_count=$(yabai -m query --spaces --space "$ws" | jq '.windows | length' 2>/dev/null || echo "0")
  fi
  
  # Return true if there are windows
  [ "$window_count" -gt 0 ]
}

# Update indicator appearance based on state
if [[ "$CURRENT_SPACE" == "$SPACE_ID" ]]; then
  # Active workspace - solid background
  sketchybar -m --set space.$SPACE_ID \
    background.drawing=on \
    background.color=0x60404040 \
    label.color=0xffdddddd
else
  # Inactive workspace - check if it has windows
  if has_windows "$SPACE_ID"; then
    # Inactive but has windows - subtle indicator
    sketchybar -m --set space.$SPACE_ID \
      background.drawing=off \
      label.color=0xffd0d0d0 \
      label.font="SF Pro:Bold:12.0"
  else
    # Empty workspace - dimmed appearance
    sketchybar -m --set space.$SPACE_ID \
      background.drawing=off \
      label.color=0x99a0a0a0 \
      label.font="SF Pro:Regular:12.0"
  fi
fi