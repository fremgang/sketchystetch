#!/bin/bash

# Network monitoring with combined display
CACHE_FILE="/tmp/sketchybar_network_cache"

# Initialize cache if it doesn't exist
if [ ! -f "$CACHE_FILE" ]; then
  echo "0 0 $(date +%s)" > "$CACHE_FILE"
fi

# Get interface (default route interface)
INTERFACE=$(route -n get default | grep interface | awk '{print $2}')

# Get current rx/tx bytes
CURRENT_RX=$(netstat -ibn | grep -e "$INTERFACE" | awk '{print $7}' | head -n1)
CURRENT_TX=$(netstat -ibn | grep -e "$INTERFACE" | awk '{print $10}' | head -n1)
CURRENT_TIME=$(date +%s)

# Read previous values
read -r PREV_RX PREV_TX PREV_TIME < "$CACHE_FILE"

# Calculate speed
TIME_DIFF=$((CURRENT_TIME - PREV_TIME))
[ $TIME_DIFF -eq 0 ] && TIME_DIFF=1  # Avoid division by zero

RX_DIFF=$((CURRENT_RX - PREV_RX))
TX_DIFF=$((CURRENT_TX - PREV_TX))

RX_SPEED=$((RX_DIFF / TIME_DIFF))
TX_SPEED=$((TX_DIFF / TIME_DIFF))

# Save current values for next time
echo "$CURRENT_RX $CURRENT_TX $CURRENT_TIME" > "$CACHE_FILE"

# Format speeds with units
format_speed() {
  local bytes=$1
  if [ "$bytes" -gt 1048576 ]; then
    echo "$(echo "scale=1; $bytes/1048576" | bc) MB/s"
  elif [ "$bytes" -gt 1024 ]; then
    echo "$(echo "scale=1; $bytes/1024" | bc) KB/s"
  else
    echo "$bytes B/s"
  fi
}

# Format the values
RX_FORMAT=$(format_speed $RX_SPEED)
TX_FORMAT=$(format_speed $TX_SPEED)

# Combined network display
LABEL="↓$RX_FORMAT ↑$TX_FORMAT"
sketchybar --set network label="$LABEL"
