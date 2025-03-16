#!/bin/bash

# network_speed.sh - Highly optimized network monitor with adaptive sampling
# Location: ~/.config/sketchybar/plugins/network_speed.sh

CACHE_FILE="/tmp/sketchybar_cache/network"
STATE_FILE="/tmp/sketchybar_cache/network_state"
LOCK_FILE="/tmp/sketchybar_locks/network.lock"
THROTTLE_TIME=5 # seconds

# Use flock for atomic operations
(
  # Non-blocking flock - skip if another instance is running
  if ! flock -n 200; then
    exit 0
  fi
  
  # Throttle execution frequency
  now=$(date +%s)
  if [ -f "$STATE_FILE" ]; then
    last_run=$(cat "$STATE_FILE")
    time_diff=$((now - last_run))
    
    # Skip if run too recently - use cached value
    if [ "$time_diff" -lt "$THROTTLE_TIME" ] && [ -f "$CACHE_FILE" ]; then
      cached_label=$(cat "$CACHE_FILE")
      sketchybar --set network label="$cached_label"
      exit 0
    fi
  fi
  
  # Record current time
  echo "$now" > "$STATE_FILE"

  # Get interface name efficiently
  INTERFACE=$(route -n get default 2>/dev/null | grep interface | awk '{print $2}' || echo "en0")
  
  # Get current stats with minimal overhead - one call to netstat
  netstat_data=$(netstat -ibn | grep -e "$INTERFACE" | head -n1)
  CURRENT_RX=$(echo "$netstat_data" | awk '{print $7}')
  CURRENT_TX=$(echo "$netstat_data" | awk '{print $10}')
  
  # Initialize or read previous values
  if [ ! -f "$CACHE_FILE.prev" ]; then
    echo "$CURRENT_RX $CURRENT_TX $now" > "$CACHE_FILE.prev"
    echo "↓0 B/s ↑0 B/s" > "$CACHE_FILE"
    sketchybar --set network label="↓0 B/s ↑0 B/s"
    exit 0
  fi
  
  # Read previous values
  read -r PREV_RX PREV_TX PREV_TIME < "$CACHE_FILE.prev"
  
  # Calculate speed - integer math for efficiency
  TIME_DIFF=$((now - PREV_TIME))
  # Prevent division by zero
  [ $TIME_DIFF -eq 0 ] && TIME_DIFF=1
  
  # Only calculate if values are valid numbers
  if [[ "$CURRENT_RX" =~ ^[0-9]+$ ]] && [[ "$PREV_RX" =~ ^[0-9]+$ ]]; then
    RX_DIFF=$((CURRENT_RX - PREV_RX))
    # Handle counter reset
    [ $RX_DIFF -lt 0 ] && RX_DIFF=$CURRENT_RX
    RX_SPEED=$((RX_DIFF / TIME_DIFF))
  else
    RX_SPEED=0
  fi
  
  if [[ "$CURRENT_TX" =~ ^[0-9]+$ ]] && [[ "$PREV_TX" =~ ^[0-9]+$ ]]; then
    TX_DIFF=$((CURRENT_TX - PREV_TX))
    # Handle counter reset
    [ $TX_DIFF -lt 0 ] && TX_DIFF=$CURRENT_TX
    TX_SPEED=$((TX_DIFF / TIME_DIFF))
  else
    TX_SPEED=0
  fi
  
  # Save current values for next time
  echo "$CURRENT_RX $CURRENT_TX $now" > "$CACHE_FILE.prev"
  
  # Optimized formatting - no bc dependency, pure bash
  format_speed() {
    local bytes=$1
    if [ "$bytes" -gt 1048576 ]; then
      echo "$((bytes / 1048576)) MB/s"
    elif [ "$bytes" -gt 1024 ]; then
      echo "$((bytes / 1024)) KB/s"
    else
      echo "$bytes B/s"
    fi
  }
  
  # Format the values
  RX_FORMAT=$(format_speed $RX_SPEED)
  TX_FORMAT=$(format_speed $TX_SPEED)
  
  # Create label
  LABEL="↓$RX_FORMAT ↑$TX_FORMAT"
  
  # Cache and set
  echo "$LABEL" > "$CACHE_FILE"
  sketchybar --set network label="$LABEL"
) 200>"$LOCK_FILE"