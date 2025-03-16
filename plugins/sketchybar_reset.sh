#!/bin/bash

# Enhanced dark theme with album art and burgundy datetime
CONFIG_DIR="$HOME/.config/sketchybar"
PLUGINS_DIR="$CONFIG_DIR/plugins"

# Kill sketchybar and clear everything
echo "Stopping sketchybar..."
pkill -x sketchybar || true
rm -f /tmp/sketchybar_* || true
sleep 1

# Start with a fresh bar with dark theme
echo "Starting fresh sketchybar with dark theme..."
sketchybar --bar height=40 \
           color=0xbb161616 \
           border_width=0 \
           shadow=off \
           position=top \
           padding_left=15 \
           padding_right=15 \
           corner_radius=0 \
           y_offset=0 \
           margin=0 \
           blur_radius=0

# Define item defaults with dark theme
sketchybar --default updates=when_shown \
                    drawing=on \
                    icon.font="SF Pro:Semibold:13.0" \
                    icon.color=0xffa0a0a0 \
                    label.font="SF Pro:Semibold:13.0" \
                    label.color=0xffa0a0a0 \
                    padding_left=5 \
                    padding_right=5 \
                    background.corner_radius=0 \
                    background.height=26 \
                    background.drawing=off

# Left side: Apple and workspaces with more spacing
echo "Adding left side items..."
sketchybar --add item apple.logo left \
           --set apple.logo \
                icon=􀣺 \
                icon.font="SF Pro:Bold:16.0" \
                icon.color=0xffa0a0a0 \
                padding_left=10 \
                padding_right=20 \
                label.drawing=off

# Add workspace indicators
sketchybar --add event aerospace_workspace_change

for sid in $(aerospace list-workspaces --all 2>/dev/null || echo "1 2 3 4 5"); do
  sketchybar --add item space.$sid left \
             --set space.$sid \
                  background.color=0x55666666 \
                  background.corner_radius=3 \
                  background.height=20 \
                  background.drawing=off \
                  label="$sid" \
                  label.color=0xffa0a0a0 \
                  padding_left=8 \
                  padding_right=8 \
                  click_script="aerospace workspace $sid && sketchybar --trigger aerospace_workspace_change space=$sid" \
                  script="$PLUGINS_DIR/aerospace_indicator.sh $sid space.$sid" \
             --subscribe space.$sid aerospace_workspace_change
done

# Add front app indicator (after workspaces)
sketchybar --add item front_app left \
           --set front_app \
                icon="􀯻" \
                icon.color=0xffa0a0a0 \
                icon.padding_right=10 \
                label.color=0xffa0a0a0 \
                padding_left=20 \
                padding_right=15 \
                script="$PLUGINS_DIR/front_app.sh" \
           --subscribe front_app front_app_switched

# RIGHT SIDE: Network status with filled icons
echo "Adding right side items..."

# Better network indicators with filled icons
sketchybar --add item network.down right \
           --set network.down \
                icon="↓" \
                icon.color=0xff888888 \
                label.color=0xff888888 \
                label.font="SF Mono:Bold:10.0" \
                padding_right=5 \
                update_freq=2

sketchybar --add item network.up right \
           --set network.up \
                icon="↑" \
                icon.color=0xff888888 \
                label.color=0xff888888 \
                label.font="SF Mono:Bold:10.0" \
                padding_right=15 \
                script="$PLUGINS_DIR/network_speed.sh" \
                update_freq=2

# Add burgundy datetime at far right
sketchybar --add item datetime right \
           --set datetime \
                icon.drawing=off \
                label.color=0xfff0f0f0 \
                label.font="SF Pro:Semibold:13.0" \
                background.color=0xbb6d1d2a \
                background.corner_radius=3 \
                background.drawing=on \
                background.height=22 \
                background.padding_left=10 \
                background.padding_right=10 \
                update_freq=1 \
                script="$PLUGINS_DIR/datetime.sh" \
                padding_right=0

# Music controls with album art
sketchybar --add item music.album left \
           --set music.album \
                icon.drawing=off \
                label.drawing=off \
                background.image.scale=0.8 \
                background.image.drawing=off \
                background.padding_left=0 \
                background.padding_right=0 \
                background.corner_radius=3 \
                width=28 \
                height=28 \
                padding_left=8 \
                padding_right=8 \
                script="$PLUGINS_DIR/music_album.sh" \
                drawing=off

sketchybar --add item music.title left \
           --set music.title \
                icon.drawing=off \
                label.color=0xffa0a0a0 \
                label.padding_left=5 \
                background.drawing=off \
                script="$PLUGINS_DIR/music_title.sh" \
                update_freq=5 \
                drawing=off \
                width=175 \
                label.width=175 \
                label.align=left

# RIGHT SIDE music controls
sketchybar --add item music.prev right \
           --set music.prev \
                icon="􀊎" \
                icon.color=0xffa0a0a0 \
                icon.padding_left=3 \
                icon.padding_right=3 \
                background.drawing=off \
                click_script="osascript -e 'tell application \"Music\" to previous track'" \
                drawing=off \
                position=left

sketchybar --add item music.play right \
           --set music.play \
                icon="􀊄" \
                icon.color=0xffa0a0a0 \
                icon.padding_left=3 \
                icon.padding_right=3 \
                background.drawing=off \
                script="$PLUGINS_DIR/music_play.sh" \
                click_script="osascript -e 'tell application \"Music\" to playpause'" \
                drawing=off \
                position=left
                
sketchybar --add item music.next right \
           --set music.next \
                icon="􀊐" \
                icon.color=0xffa0a0a0 \
                icon.padding_left=3 \
                icon.padding_right=10 \
                background.drawing=off \
                click_script="osascript -e 'tell application \"Music\" to next track'" \
                drawing=off \
                position=left

# Update and finalize
echo "Updating item states..."
CURRENT_SPACE=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
sketchybar --trigger aerospace_workspace_change space="$CURRENT_SPACE"

# Initial update of music controls
"$PLUGINS_DIR/music_play.sh"

echo "Complete rebuild of sketchybar finished with dark theme!"