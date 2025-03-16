#!/bin/bash

# Kill existing instance if needed
pkill -x sketchybar 2>/dev/null

# Wait briefly
sleep 0.5

# Create bar
sketchybar -m --bar height=36 color=0xee181818 position=top padding_left=10 padding_right=10

# Set defaults
sketchybar -m --default label.color=0xffffffff icon.color=0xffffffff

# Add items (with the -m flag and separate the add and set commands)
sketchybar -m --add item test_text left
sleep 0.1
sketchybar -m --set test_text label="Test Working" icon="💻"

# Add time
sketchybar -m --add item time right
sleep 0.1
sketchybar -m --set time label="$(date '+%H:%M')" update_freq=1
