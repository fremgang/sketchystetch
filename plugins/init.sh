#!/bin/bash

# init.sh - Fast startup script for sketchybar
# Location: ~/.config/sketchybar/plugins/init.sh

# Determine paths from parent directory
PLUGINS_DIR="$(dirname "$0")"
CACHE_DIR="/tmp/sketchybar_cache"
LOCK_DIR="/tmp/sketchybar_locks"

# Create cache directory
mkdir -p "$CACHE_DIR" "$LOCK_DIR"

# Set proper permissions
chmod 700 "$CACHE_DIR" "$LOCK_DIR"

# Remove stale locks
rm -f "$LOCK_DIR"/*.lock

# Execute core plugins in parallel for faster startup
"$PLUGINS_DIR/workspaces.sh" &
"$PLUGINS_DIR/front_app.sh" &
"$PLUGINS_DIR/datetime.sh" &

# Slightly delay network monitor to avoid startup congestion
(sleep 0.5 && "$PLUGINS_DIR/network_speed.sh") &

# Check if music is running, start that monitor only if needed
if pgrep -q "Music"; then
  "$PLUGINS_DIR/music_info.sh" &
fi

wait