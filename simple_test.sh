#!/bin/bash
# Save as simple_test.sh

# Kill existing instance
pkill -x sketchybar

# Reset and create a minimal bar
sketchybar --bar height=36 color=0xee181818 position=top padding_left=10 padding_right=10
sketchybar --default label.color=0xffffffff

# Add a basic text item 
sketchybar --add item time right
sketchybar --set time label="$(date '+%H:%M')" update_freq=1
sketchybar --subscribe time system_woke

# Add a simple text item
sketchybar --add item test_text left
sketchybar --set test_text label="Test Working" icon="💻"
