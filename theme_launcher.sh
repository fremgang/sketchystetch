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
