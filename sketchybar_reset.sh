#!/bin/bash

# r/unixporn-quality sketchybar configuration - Final Version
# Usage: ./sketchybar_reset.sh [theme]
# Available themes: dark (default), dark_egg, dark_pink, apres_ski

CONFIG_DIR="$HOME/.config/sketchybar"
PLUGINS_DIR="$CONFIG_DIR/plugins"

# Theme selection (default to dark if not specified)
THEME=${1:-dark}

# Define color palettes with subtle gradients and transparency
case "$THEME" in
  "dark_pink")
    echo "Applying Dark Pink theme..."
    BG_COLOR="0xee202020"
    MODULE_BG="0x44282828"
    ACCENT1="0x55CA3E47"
    ACCENT2="0x40525252"
    ACCENT3="0x33414141"
    FG_COLOR="0xffdadada"
    ICON_COLOR="0xffeaeaea"
    HIGHLIGHT="0xffCA3E47"
    ;;
  "dark_egg")
    echo "Applying Dark Egg theme..."
    BG_COLOR="0xee151515"
    MODULE_BG="0x44202020"
    ACCENT1="0x40854836"
    ACCENT2="0x30FFB22C" 
    ACCENT3="0x33333333"
    FG_COLOR="0xffdadada"
    ICON_COLOR="0xffeaeaea"
    HIGHLIGHT="0xffFFB22C"
    ;;
  "apres_ski")
    echo "Applying Après Ski theme..."
    BG_COLOR="0xee101010"
    MODULE_BG="0x44202020"
    ACCENT1="0x330D1282"
    ACCENT2="0x33F0DE36"
    ACCENT3="0x25D71313"
    FG_COLOR="0xffdadada"
    ICON_COLOR="0xffeaeaea"
    HIGHLIGHT="0xffF0DE36"
    ;;
  *)
    echo "Applying Dark theme..."
    BG_COLOR="0xee181818"
    MODULE_BG="0x44252525"
    ACCENT1="0x33303030"
    ACCENT2="0x33353535"
    ACCENT3="0x33404040"
    FG_COLOR="0xffb8b8b8"
    ICON_COLOR="0xffbbbbbb"
    HIGHLIGHT="0xffd0d0d0"
    ;;
esac

# Create scripts first
echo "Creating plugin scripts..."
mkdir -p "$PLUGINS_DIR"

# Workspaces script
cat > "$PLUGINS_DIR/workspaces.sh" << 'EOF'
#!/bin/bash

# Get current workspace
CURRENT=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")
WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null || echo "1 2 3 4 5")

# Build labels
LABEL=""
for ws in $WORKSPACES; do
  if [[ "$ws" == "$CURRENT" ]]; then
    LABEL+="●"
  else
    LABEL+="○"
  fi
  LABEL+=" "
done

# Set label
sketchybar --set workspaces label="$LABEL"
EOF
chmod +x "$PLUGINS_DIR/workspaces.sh"

# Front app script
cat > "$PLUGINS_DIR/front_app.sh" << 'EOF'
#!/bin/bash

# Get the front app name
FRONT_APP=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true')

# Limit to a reasonable length
if [[ ${#FRONT_APP} -gt 25 ]]; then
  FRONT_APP="${FRONT_APP:0:22}..."
fi

# Update the label with the app name
sketchybar --set front_app label="$FRONT_APP"
EOF
chmod +x "$PLUGINS_DIR/front_app.sh"

# Network speed script
cat > "$PLUGINS_DIR/network_speed.sh" << 'EOF'
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
EOF
chmod +x "$PLUGINS_DIR/network_speed.sh"

# Datetime script
cat > "$PLUGINS_DIR/datetime.sh" << 'EOF'
#!/bin/bash

# Format date and time
TIME=$(date +"%H:%M")
DATE=$(date +"%a %d")

# Combined display
DATETIME="$TIME · $DATE"

# Set the label
sketchybar --set datetime label="$DATETIME"
EOF
chmod +x "$PLUGINS_DIR/datetime.sh"

# Music info script (simplified, no controls)
cat > "$PLUGINS_DIR/music_info.sh" << 'EOF'
#!/bin/bash

# Check if Music is running
if ! pgrep -x "Music" >/dev/null; then
  sketchybar --set music.info drawing=off
  exit 0
fi

# Check if music is playing or paused
STATE=$(osascript -e 'tell application "Music" to player state as string')
if [[ "$STATE" != "playing" && "$STATE" != "paused" ]]; then
  sketchybar --set music.info drawing=off
  exit 0
fi

# Get track info
TRACK=$(osascript -e 'tell application "Music" to name of current track')
ARTIST=$(osascript -e 'tell application "Music" to artist of current track')

# Format track info
if [[ ${#TRACK} -gt 30 ]]; then
  TRACK="${TRACK:0:27}..."
fi

if [[ ${#ARTIST} -gt 18 ]]; then
  ARTIST="${ARTIST:0:15}..."
fi

# Update label - just show track and artist info, no controls
LABEL="$TRACK — $ARTIST"
sketchybar --set music.info label="$LABEL" drawing=on
EOF
chmod +x "$PLUGINS_DIR/music_info.sh"

# Create a theme launcher script
cat > "$CONFIG_DIR/theme_launcher.sh" << 'EOF'
#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"

echo "Select a theme:"
echo "1) Dark (Default)"
echo "2) Dark Egg"
echo "3) Dark Pink"
echo "4) Après Ski"
read -p "Enter selection (1-4): " choice

case $choice in
  1) 
    theme="dark"
    ;;
  2)
    theme="dark_egg"
    ;;
  3)
    theme="dark_pink"
    ;;
  4)
    theme="apres_ski"
    ;;
  *)
    echo "Invalid choice. Using default theme."
    theme="dark"
    ;;
esac

"$CONFIG_DIR/sketchybar_reset.sh" "$theme"
EOF
chmod +x "$CONFIG_DIR/theme_launcher.sh"

# Kill any running instance
echo "Stopping sketchybar..."
pkill -x sketchybar || true
rm -rf /tmp/sketchybar_* || true
mkdir -p /tmp/sketchybar_album_art
sleep 1

# Start fresh sketchybar
echo "Starting fresh sketchybar with premium design..."

# Main bar with drop shadow effect
sketchybar --bar height=36 \
           color=$BG_COLOR \
           border_width=0 \
           shadow=on \
           position=top \
           padding_left=10 \
           padding_right=10 \
           corner_radius=0 \
           y_offset=0 \
           margin=0 \
           blur_radius=0

# Default styling for all items
sketchybar --default updates=when_shown \
                    drawing=on \
                    icon.font="SF Pro:Semibold:12.0" \
                    icon.color=$ICON_COLOR \
                    label.font="SF Pro:Regular:12.0" \
                    label.color=$FG_COLOR \
                    background.height=26 \
                    background.corner_radius=4 \
                    background.drawing=off

# Create items one by one with subtle color accents
echo "Creating all modules with subtle color integration..."

# Left side - Apple logo
sketchybar --add item apple.logo left \
           --set apple.logo \
                background.color=$MODULE_BG \
                background.height=26 \
                background.padding_left=10 \
                background.padding_right=10 \
                background.drawing=on \
                background.border_width=0 \
                background.border_color=$ACCENT1 \
                icon=􀣺 \
                icon.font="SF Pro:Bold:13.0" \
                icon.color=$HIGHLIGHT \
                label.drawing=off

# App name on left side
sketchybar --add item front_app left \
           --set front_app \
                background.color=$MODULE_BG \
                background.height=26 \
                background.padding_left=8 \
                background.padding_right=10 \
                background.drawing=on \
                background.border_width=0 \
                background.border_color=$ACCENT3 \
                icon=􀏜 \
                icon.color=$HIGHLIGHT \
                icon.padding_right=6 \
                label.color=$FG_COLOR

# Workspace indicators in center
sketchybar --add item workspaces center \
           --set workspaces \
                position=center \
                background.color=$MODULE_BG \
                background.height=26 \
                background.padding_left=10 \
                background.padding_right=10 \
                background.drawing=on \
                background.border_width=0 \
                background.border_color=$ACCENT2 \
                icon.drawing=off \
                label.drawing=on \
                label.font="SF Pro:Medium:11.5" \
                label.color=$ICON_COLOR

# Network stats 
sketchybar --add item network right \
           --set network \
                background.color=$MODULE_BG \
                background.height=26 \
                background.padding_left=8 \
                background.padding_right=8 \
                background.drawing=on \
                background.border_width=0 \
                background.border_color=$ACCENT2 \
                icon=􀤆 \
                icon.font="SF Pro:Regular:12.0" \
                icon.color=$HIGHLIGHT \
                icon.padding_right=6 \
                label.color=$FG_COLOR \
                label.font="SF Mono:Regular:10.0"

# Add separator
sketchybar --add item separator2 right \
           --set separator2 \
                width=8 \
                icon.drawing=off \
                label.drawing=off

# Music info (track only, no controls, no icon)
sketchybar --add item music.info right \
           --set music.info \
                background.color=$MODULE_BG \
                background.height=26 \
                background.padding_left=8 \
                background.padding_right=8 \
                background.drawing=on \
                background.border_width=0 \
                background.border_color=$ACCENT1 \
                icon.drawing=off \
                label.color=$FG_COLOR \
                label.font="SF Pro:Regular:11.5" \
                drawing=off

# Add separator
sketchybar --add item separator3 right \
           --set separator3 \
                width=8 \
                icon.drawing=off \
                label.drawing=off

# Date and time - moved after music info
sketchybar --add item datetime right \
           --set datetime \
                background.color=$MODULE_BG \
                background.height=26 \
                background.padding_left=8 \
                background.padding_right=8 \
                background.drawing=on \
                background.border_width=0 \
                background.border_color=$ACCENT3 \
                icon.drawing=off \
                label.font="SF Pro:Medium:11.5" \
                label.color=$FG_COLOR

# Add event subscriptions
sketchybar --add event aerospace_workspace_change \
           --subscribe front_app front_app_switched

# Let sketchybar finish initializing items
sleep 1

# Now run the scripts to populate data
echo "Updating all modules..."
"$PLUGINS_DIR/workspaces.sh"
"$PLUGINS_DIR/front_app.sh"
"$PLUGINS_DIR/network_speed.sh"
"$PLUGINS_DIR/music_info.sh"
"$PLUGINS_DIR/datetime.sh"

echo "r/unixporn-quality sketchybar with subtle $THEME theme complete!"
echo "To change themes, run: $CONFIG_DIR/theme_launcher.sh"