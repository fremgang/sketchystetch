#!/bin/bash

# cache.sh - Cache management utilities for sketchybar
# Location: ~/.config/sketchybar/utils/cache.sh

CACHE_DIR="/tmp/sketchybar_cache"
LOCK_DIR="/tmp/sketchybar_locks"

# Command handlers
case "$1" in
  "clear")
    echo "Clearing sketchybar cache..."
    find "$CACHE_DIR" -type f -not -name "runtime_id" -delete 2>/dev/null
    rm -f "$LOCK_DIR"/*.lock 2>/dev/null
    echo "Cache cleared!"
    ;;
    
  "status")
    echo "Sketchybar cache status:"
    echo "------------------------"
    
    # Cache directory info
    echo "Cache directory: $CACHE_DIR"
    cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}')
    echo "Cache size: ${cache_size:-0B}"
    
    # File count
    file_count=$(find "$CACHE_DIR" -type f | wc -l)
    echo "Cache files: $file_count"
    
    # Runtime status
    if [ -f "$CACHE_DIR/runtime_id" ]; then
      runtime_id=$(cat "$CACHE_DIR/runtime_id")
      echo "Runtime ID: $runtime_id"
    else
      echo "Runtime ID: Not found"
    fi
    
    # Lock status
    active_locks=$(find "$LOCK_DIR" -type f -name "*.lock" | wc -l)
    echo "Active locks: $active_locks"
    
    # List lock files if any
    if [ "$active_locks" -gt 0 ]; then
      echo ""
      echo "Active lock files:"
      find "$LOCK_DIR" -type f -name "*.lock" | while read -r lock; do
        lock_name=$(basename "$lock")
        lock_pid=$(fuser "$lock" 2>/dev/null)
        if [ -n "$lock_pid" ]; then
          lock_process=$(ps -p "$lock_pid" -o comm= 2>/dev/null)
          echo "- $lock_name (PID: $lock_pid, Process: $lock_process)"
        else
          echo "- $lock_name (stale)"
        fi
      done
    fi
    ;;
    
  "debug")
    echo "Sketchybar debug information:"
    echo "---------------------------"
    
    # Check sketchybar process
    if pgrep -x "sketchybar" > /dev/null; then
      echo "Status: Running"
      pid=$(pgrep -x "sketchybar")
      echo "PID: $pid"
      runtime=$(ps -p "$pid" -o etime= 2>/dev/null)
      echo "Uptime: $runtime"
      memory=$(ps -p "$pid" -o rss= 2>/dev/null)
      if [ -n "$memory" ]; then
        memory_mb=$(echo "scale=2; $memory/1024" | bc)
        echo "Memory: ${memory_mb}MB"
      fi
    else
      echo "Status: Not running"
    fi
    
    # Check integration status
    echo ""
    echo "Integration status:"
    
    if [ -f "$HOME/.config/skhd/sketchybar_aerospace.skhd" ]; then
      echo "SKHD: Configured"
    else
      echo "SKHD: Not configured"
    fi
    
    if grep -q "exec-on-workspace-change.*sketchybar" "$HOME/.config/aerospace/aerospace.toml" 2>/dev/null; then
      echo "Aerospace: Configured"
    else
      echo "Aerospace: Not configured"
    fi
    
    # Check recent events
    echo ""
    echo "Recent cache updates:"
    find "$CACHE_DIR" -type f -not -name "runtime_id" -mmin -5 | while read -r file; do
      filename=$(basename "$file")
      modified=$(stat -f "%Sm" -t "%H:%M:%S" "$file")
      echo "- $filename (last updated: $modified)"
    done
    ;;
    
  "clean")
    echo "Cleaning up stale locks and cache..."
    
    # Remove stale locks
    find "$LOCK_DIR" -type f -name "*.lock" | while read -r lock; do
      if ! fuser "$lock" >/dev/null 2>&1; then
        echo "Removing stale lock: $(basename "$lock")"
        rm -f "$lock"
      fi
    done
    
    # Remove old cache files
    find "$CACHE_DIR" -type f -not -name "runtime_id" -mmin +60 -delete 2>/dev/null
    
    echo "Cleanup complete!"
    ;;
    
  *)
    echo "Sketchybar Cache Utility"
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  clear    - Clear all cache files"
    echo "  status   - Show cache status"
    echo "  debug    - Show detailed debugging information"
    echo "  clean    - Clean up stale locks and old cache files"
    ;;
esac