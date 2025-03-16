#!/bin/bash
# Save this as ~/.config/sketchybar/test_basic.sh

# Reset everything
sketchybar --bar height=36 color=0xee181818 position=top padding_left=10 padding_right=10

# Remove all items first
sketchybar -m --remove-all

# Add a simple text item
sketchybar -m --add item test_text left
sketchybar -m --set test_text label="Test Working" icon=💻