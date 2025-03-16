#!/bin/bash

# music_info.sh - High-performance music info display with state tracking
# Location: ~/.config/sketchybar/plugins/music_info.sh

CACHE_DIR="/tmp/sketchybar_cache"
CACHE_FILE="$CACHE_DIR/music_info"
STATE_FILE="$CACHE_DIR/music_state"
LOCK_FILE="/tmp/sketchybar_locks/music.lock"

# Use flock for thread safety
(
  # Non-blocking lock - skip if another instance is running
  if ! flock -n 200; then
    exit 0
  fi
  
  # Fast check if Music is running using pgrep (much faster than osascript)
  if ! pgrep -q "Music"; then
    # Hide the item if Music isn't running
    sketchybar --set music.info drawing=off
    # Clean up state
    rm -f "$STATE_FILE" "$CACHE_FILE" 2>/dev/null
    exit 0
  fi
  
  # Get Music process ID for state tracking
  music_pid=$(pgrep -x "Music" | head -1)
  
  # Skip update if state is unchanged since last check
  if [ -f "$STATE_FILE" ]; then
    read -r last_pid last_check < "$STATE_FILE"
    now=$(date +%s)
    
    # Only check every 2 seconds max unless pid changed
    if [ "$last_pid" = "$music_pid" ] && [ $((now - last_check)) -lt 2 ] && [ -f "$CACHE_FILE" ]; then
      # Re-use cached info
      cached_label=$(cat "$CACHE_FILE")
      sketchybar --set music.info label="$cached_label" drawing=on
      exit 0
    fi
  fi
  
  # Update state file
  echo "$music_pid $(date +%s)" > "$STATE_FILE"
  
  # Combined osascript call for better performance - gets all info at once
  music_info=$(osascript -e '
    if application "Music" is running then
      tell application "Music"
        if player state is playing or player state is paused then
          set trackName to name of current track
          set artistName to artist of current track
          set playerState to player state
          return trackName & "|" & artistName & "|" & playerState
        else
          return "not_playing"
        end if
      end tell
    else
      return "not_running"
    end if
  ')
  
  # Handle error or not playing
  if [ "$music_info" = "not_playing" ] || [ "$music_info" = "not_running" ]; then
    sketchybar --set music.info drawing=off
    rm -f "$CACHE_FILE" 2>/dev/null
    exit 0
  fi
  
  # Parse the response
  TRACK=$(echo "$music_info" | cut -d'|' -f1)
  ARTIST=$(echo "$music_info" | cut -d'|' -f2)
  
  # Efficient truncation
  if [ ${#TRACK} -gt 30 ]; then
    TRACK="${TRACK:0:27}..."
  fi
  
  if [ ${#ARTIST} -gt 18 ]; then
    ARTIST="${ARTIST:0:15}..."
  fi
  
  # Format label
  LABEL="$TRACK — $ARTIST"
  
  # Cache and set
  echo "$LABEL" > "$CACHE_FILE"
  sketchybar --set music.info label="$LABEL" drawing=on
) 200>"$LOCK_FILE"