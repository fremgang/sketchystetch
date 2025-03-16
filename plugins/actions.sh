#!/bin/bash

# actions.sh - Handles various click actions and menu interactions
# Location: ~/.config/sketchybar/plugins/actions.sh

ACTION=$1
shift

case "$ACTION" in
  "apple_click")
    # Create a system menu when clicking the Apple logo
    TEMP_FILE="/tmp/sketchybar_menu_$$.json"
    
    cat > "$TEMP_FILE" << EOF
    {
      "items": [
        {
          "name": "About This Mac",
          "shortcut": "",
          "action": "osascript -e 'tell application \"System Events\" to tell process \"Finder\" to click menu item \"About This Mac\" of menu \"Apple\" of menu bar 1'"
        },
        { "type": "separator" },
        {
          "name": "System Settings",
          "shortcut": "",
          "action": "open -a 'System Settings.app'"
        },
        {
          "name": "App Store",
          "shortcut": "",
          "action": "open -a 'App Store.app'"
        },
        { "type": "separator" },
        {
          "name": "Sketchybar Theme",
          "shortcut": "",
          "submenu": [
            {
              "name": "Dark",
              "action": "$HOME/.config/sketchybar/utils/theme_launcher.sh dark"
            },
            {
              "name": "Dark Pink",
              "action": "$HOME/.config/sketchybar/utils/theme_launcher.sh dark_pink" 
            },
            {
              "name": "Dark Egg",
              "action": "$HOME/.config/sketchybar/utils/theme_launcher.sh dark_egg"
            },
            {
              "name": "Après Ski",
              "action": "$HOME/.config/sketchybar/utils/theme_launcher.sh apres_ski"
            }
          ]
        },
        { "type": "separator" },
        {
          "name": "Sleep",
          "shortcut": "",
          "action": "osascript -e 'tell application \"System Events\" to sleep'"
        },
        {
          "name": "Restart",
          "shortcut": "⌥⌘⏏",
          "action": "osascript -e 'tell application \"System Events\" to restart'"
        },
        {
          "name": "Shut Down",
          "shortcut": "⌃⏏",
          "action": "osascript -e 'tell application \"System Events\" to shut down'"
        },
        { "type": "separator" },
        {
          "name": "Lock Screen",
          "shortcut": "⌃⌘Q",
          "action": "osascript -e 'tell application \"System Events\" to keystroke \"q\" using {command down, control down}'"
        },
        {
          "name": "Log Out",
          "shortcut": "⇧⌘Q",
          "action": "osascript -e 'tell application \"System Events\" to log out'"
        }
      ]
    }
EOF
    
    # Show the menu
    sketchybar --menu apple.logo "$TEMP_FILE"
    rm "$TEMP_FILE"
    ;;
    
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac