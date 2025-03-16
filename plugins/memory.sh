#!/bin/bash

# memory.sh - Show memory usage
# Location: ~/.config/sketchybar/plugins/memory.sh

# Format memory size
format_size() {
  local bytes=$1
  
  if [ "$bytes" -ge 1073741824 ]; then
    echo "$(( bytes / 1073741824 )).$((( bytes % 1073741824 ) / 107374182 ))G"
  elif [ "$bytes" -ge 1048576 ]; then
    echo "$(( bytes / 1048576 )).$((( bytes % 1048576 ) / 104858 ))M"
  else
    echo "$(( bytes / 1024 ))K"
  fi
}

# Get memory information using vm_stat (faster than top)
memory_info() {
  # Get page size (normally 4096 bytes on macOS)
  local page_size=4096
  
  # Get total memory
  local total_memory
  total_memory=$(sysctl -n hw.memsize)
  
  # Get memory usage via vm_stat
  local vm_stat
  vm_stat=$(vm_stat)
  
  # Parse vm_stat output
  local pages_free
  pages_free=$(echo "$vm_stat" | grep "Pages free" | awk '{print $3}' | tr -d '.')
  
  local pages_active
  pages_active=$(echo "$vm_stat" | grep "Pages active" | awk '{print $3}' | tr -d '.')
  
  local pages_inactive
  pages_inactive=$(echo "$vm_stat" | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
  
  local pages_speculative
  pages_speculative=$(echo "$vm_stat" | grep "Pages speculative" | awk '{print $3}' | tr -d '.')
  
  local pages_wired
  pages_wired=$(echo "$vm_stat" | grep "Pages wired down" | awk '{print $4}' | tr -d '.')
  
  # Calculate used memory
  local used_memory
  used_memory=$(( (pages_active + pages_wired) * page_size ))
  
  # Calculate free memory
  local free_memory
  free_memory=$(( (pages_free + pages_inactive + pages_speculative) * page_size ))
  
  # Calculate percentage
  local percentage
  percentage=$(( used_memory * 100 / total_memory ))
  
  # Format for display
  local formatted_used
  formatted_used=$(format_size "$used_memory")
  
  local formatted_total
  formatted_total=$(format_size "$total_memory")
  
  echo "$percentage|$formatted_used|$formatted_total"
}

# Get and format memory info
INFO=$(memory_info)
PERCENTAGE=$(echo "$INFO" | cut -d'|' -f1)
USED=$(echo "$INFO" | cut -d'|' -f2)
TOTAL=$(echo "$INFO" | cut -d'|' -f3)

# Display with color-coded percentage
sketchybar -m --set memory label="${PERCENTAGE}% (${USED})"