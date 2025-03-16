#!/bin/bash

# Optimized sketchybar config for MacBook Air with notch
# Location: ~/.config/sketchybar/sketchybar_config.sh

# === DIRECTORY SETUP ===
CONFIG_DIR="$HOME/.config/sketchybar"
PLUGINS_DIR="$CONFIG_DIR/plugins"
CACHE_DIR="/tmp/sketchybar_cache"
mkdir -p "$CACHE_DIR"

# === THEME COLORS ===
BAR_COLOR="0xee181818"
MODULE_BG="0x55252525"
ACCENT_COLOR="0xffd0d0d0"
ICON_COLOR="0xffbbbbbb"
LABEL_COLOR="0xffb8b8b8"
FONT="SF Pro"

# === CLEANUP PREVIOUS INSTANCE ===
pkill -x sketchybar 2>/dev/null
sleep 0.5
rm -f "$CACHE_DIR"/* 2>/dev/null


# === BAR CONFIGURATION ===
sketchybar -m --bar height=36 \
           color=$BAR_COLOR \
           border_width=0 \
           shadow=off \
           position=top \
           padding_left=15 \
           padding_right=15 \
           y_offset=0 \
           margin=0 \
           notch_width=0 \
           display=main

# === DEFAULT STYLING ===
sketchybar -m --default updates=when_shown \
                    drawing=on \
                    icon.font="sketchybar-app-font:Regular:16.0" \
                    icon.color=$ICON_COLOR \
                    label.font="$FONT:Regular:14.0" \
                    label.color=$LABEL_COLOR \
                    background.height=26 \
                    background.corner_radius=4 \
                    background.drawing=off \
                    padding_left=5 \
                    padding_right=5

sketchybar -m --add item spacer1 left
sketchybar -m --set spacer1 width=20

sketchybar -m --add item spacer2 right 
sketchybar -m --set spacer2 width=20



# === EVENTS ===
sketchybar -m --add event aerospace_workspace_change
sketchybar -m --add event system_woke
sketchybar -m --add event window_focus
sketchybar -m --add event music_change

# === LEFT MODULES ===
# Apple logo - Static element
sketchybar -m --add item apple.logo left \
           --set apple.logo \
                background.color=$MODULE_BG \
                background.height=26 \
                background.padding_left=10 \
                background.padding_right=10 \
                background.drawing=on \
                icon=􀣺 \
                icon.font="$FONT:Bold:13.0" \
                icon.color=$ACCENT_COLOR \
                label.drawing=off \
                padding_right=8

# Active workspace apps
sketchybar -m --add item active_apps right \
           --set active_apps \
                background.color=$MODULE_BG \
                background.height=26 \
                background.corner_radius=4 \
                background.drawing=on \
                background.padding_left=8 \
                background.padding_right=8 \
                label.color=$LABEL_COLOR \
                update_freq=2 \
                script="$PLUGINS_DIR/active_apps.sh"

# === WORKSPACES (LEFT SIDE, AVOIDING NOTCH) ===
# Create a spacer to push items away from the notch
sketchybar -m --add item left_spacer left \
           --set left_spacer padding_right=170

# Add workspace indicators on the left side only
for i in {1..9}; do
  sketchybar -m --add item space.$i left \
             --set space.$i \
                  background.color=$MODULE_BG \
                  background.height=22 \
                  background.corner_radius=4 \
                  background.drawing=off \
                  icon.drawing=off \
                  label="$i" \
                  label.font="$FONT:Bold:12.0" \
                  label.color=$LABEL_COLOR \
                  label.padding_left=6 \
                  label.padding_right=6 \
                  script="$PLUGINS_DIR/space.sh $i" \
                  click_script="aerospace workspace $i && sketchybar -m --trigger aerospace_workspace_change space=$i" \
                  padding_left=3 \
                  padding_right=3 \
             --subscribe space.$i aerospace_workspace_change
done

# === RIGHT MODULES (WITH BETTER SPACING) ===
# Date and time (moved to rightmost position)
sketchybar -m --add item datetime right \
           --set datetime \
                background.color=$MODULE_BG \
                background.height=26 \
                background.corner_radius=4 \
                background.drawing=on \
                background.padding_left=10 \
                background.padding_right=10 \
                icon.drawing=off \
                label.font="$FONT:Medium:11.5" \
                label.color=$LABEL_COLOR \
                update_freq=30 \
                script="$PLUGINS_DIR/datetime.sh" \
                padding_left=8 \
                padding_right=5 \
           --subscribe datetime system_woke

# Network monitor (with fixed width)
sketchybar -m --add item network right \
           --set network \
                background.color=$MODULE_BG \
                background.height=26 \
                background.corner_radius=4 \
                background.drawing=on \
                background.padding_left=8 \
                background.padding_right=8 \
                icon=􀤆 \
                icon.font="$FONT:Regular:12.0" \
                icon.color=$ACCENT_COLOR \
                label.color=$LABEL_COLOR \
                label.font="SF Mono:Regular:10.0" \
                update_freq=2 \
                script="$PLUGINS_DIR/network.sh" \
                padding_left=12 \
                padding_right=12

# Music info (track and artist)
sketchybar -m --add item music.title right \
           --set music.title \
                background.color=$MODULE_BG \
                background.corner_radius=4 \
                background.drawing=on \
                background.padding_left=8 \
                background.padding_right=8 \
                background.height=26 \
                icon.drawing=off \
                label.color=$LABEL_COLOR \
                label.font="$FONT:Regular:11.0" \
                script="$PLUGINS_DIR/music.sh" \
                drawing=off \
                update_freq=5 \
                padding_left=8 \
                padding_right=8 \
           --subscribe music.title music_change

# Music module with album art
sketchybar -m --add item music.album right \
           --set music.album \
                background.height=22 \
                background.corner_radius=4 \
                background.padding_left=0 \
                background.padding_right=0 \
                background.drawing=off \
                background.image.scale=0.8 \
                background.image.drawing=off \
                icon.drawing=off \
                label.drawing=off \
                width=24 \
                drawing=off \
                padding_right=0 \
                padding_left=5

# Initialize bar and update music display
sketchybar -m --update
"$PLUGINS_DIR/music.sh" &