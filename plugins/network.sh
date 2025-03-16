#!/bin/bash

# network.sh - Reliable network speed monitoring with fixed width
# Location: ~/.config/sketchybar/plugins/network.sh

CACHE_FILE="/tmp/sketchybar_cache/network_stats"

# Create cache file if it doesn't exist
mkdir -p "$(dirname "$CACHE_FILE")"
[ ! -f "$CACHE_FILE" ] && echo "0 0 $(date +%s)" > "$CACHE_FILE"

# Get current time
CURRENT_TIME=$(date +%s)

# Get interface (default route interface)
INTERFACE=$(route -n get default | grep interface | awk '{print $2}')
[ -z "$INTERFACE" ] && INTERFACE="en0"  # Fallback

# Get current rx/tx bytes
# Try different netstat parsing approaches (for different macOS versions)
netstat_data=$(netstat -ibn | grep -e "$INTERFACE" | head -n1)
CURRENT_RX=$(echo "$netstat_data" | awk '{print $7}')
CURRENT_TX=$(echo "$netstat_data" | awk '{print $10}')

# Fallback parsing if the above fails
if [ -z "$CURRENT_RX" ] || [ -z "$CURRENT_TX" ]; then
  CURRENT_RX=$(echo "$netstat_data" | grep -oE 'ibytes=[0-9]+' | cut -d= -f2)
  CURRENT_TX=$(echo "$netstat_data" | grep -oE 'obytes=[0-9]+' | cut -d= -f2)
fi

# Fallback again if previous methods fail
if [ -z "$CURRENT_RX" ] || [ -z "$CURRENT_TX" ]; then
  # List all network interfaces and grep for the active one
  all_interfaces=$(ifconfig -a | grep -E '^[a-z0-9]+:' | cut -d: -f1)
  for iface in $all_interfaces; do
    if ifconfig "$iface" | grep -q "status: active"; then
      INTERFACE="$iface"
      CURRENT_RX=$(netstat -I "$INTERFACE" -b | tail -1 | awk '{print $7}')
      CURRENT_TX=$(netstat -I "$INTERFACE" -b | tail -1 | awk '{print $10}')
      break
    fi
  done
fi

# If still no data, use zeros
[ -z "$CURRENT_RX" ] && CURRENT_RX=0
[ -z "$CURRENT_TX" ] && CURRENT_TX=0

# Read previous values
read -r PREV_RX PREV_TX PREV_TIME < "$CACHE_FILE"

# Calculate speed - use integer math for efficiency
TIME_DIFF=$((CURRENT_TIME - PREV_TIME))
[ $TIME_DIFF -eq 0 ] && TIME_DIFF=1  # Avoid division by zero

# Only calculate if values are valid numbers and time diff is reasonable
if [[ $CURRENT_RX =~ ^[0-9]+$ ]] && [[ $PREV_RX =~ ^[0-9]+$ ]] && [ $TIME_DIFF -gt 0 ] && [ $TIME_DIFF -lt 60 ]; then
  RX_DIFF=$((CURRENT_RX - PREV_RX))
  # Handle counter reset (if device was restarted)
  [ $RX_DIFF -lt 0 ] && RX_DIFF=$CURRENT_RX
  RX_SPEED=$((RX_DIFF / TIME_DIFF))
else
  RX_SPEED=0
fi

if [[ $CURRENT_TX =~ ^[0-9]+$ ]] && [[ $PREV_TX =~ ^[0-9]+$ ]] && [ $TIME_DIFF -gt 0 ] && [ $TIME_DIFF -lt 60 ]; then
  TX_DIFF=$((CURRENT_TX - PREV_TX))
  # Handle counter reset (if device was restarted)
  [ $TX_DIFF -lt 0 ] && TX_DIFF=$CURRENT_TX
  TX_SPEED=$((TX_DIFF / TIME_DIFF))
else
  TX_SPEED=0
fi

# Save current values for next time
echo "$CURRENT_RX $CURRENT_TX $CURRENT_TIME" > "$CACHE_FILE"

# Format speeds with FIXED WIDTH for consistency
format_speed() {
  local bytes=$1
  local formatted=""
  
  if [ "$bytes" -gt 1048576 ]; then # 1MB
    formatted=$(printf "%4.1f MB/s" "$(echo "scale=1; $bytes/1048576" | bc)")
  elif [ "$bytes" -gt 1024 ]; then
    formatted=$(printf "%4.1f KB/s" "$(echo "scale=1; $bytes/1024" | bc)")
  else
    formatted=$(printf "%4d B/s" "$bytes")
  fi
  
  # Ensure consistent width
  printf "%-9s" "$formatted"
}

# Format the values with fixed width
RX_FORMAT=$(format_speed $RX_SPEED)
TX_FORMAT=$(format_speed $TX_SPEED)

# Combined network display with fixed width
sketchybar -m --set network label="↓${RX_FORMAT} ↑${TX_FORMAT}"