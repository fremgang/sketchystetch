#!/bin/bash

# theme.sh - Theme definitions for sketchybar
# Location: ~/.config/sketchybar/theme.sh

# Default font
FONT="SF Pro"

# Theme selection
THEME=${1:-dark}

# Load theme-specific settings if available
if [ -f "$CONFIG_DIR/themes/$THEME.sh" ]; then
  source "$CONFIG_DIR/themes/$THEME.sh"
  echo "Loaded theme: $THEME"
else
  # Default theme colors (dark)
  BAR_COLOR="0xee181818"
  MODULE_BG="0x44252525"
  ACCENT_COLOR="0xffd0d0d0"
  ICON_COLOR="0xffbbbbbb"
  LABEL_COLOR="0xffb8b8b8"
  
  echo "Using default dark theme"
fi