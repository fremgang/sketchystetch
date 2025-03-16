#!/bin/bash

# theme_launcher.sh - Interactive theme selector with preview
# Location: ~/.config/sketchybar/utils/theme_launcher.sh

CONFIG_DIR="$HOME/.config/sketchybar"

# Terminal colors for preview
RESET="\033[0m"
BOLD="\033[1m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Function to preview theme
preview_theme() {
  case "$1" in
    "dark")
      echo -e "${BOLD}${WHITE}${BG_BLACK} Dark Theme ${RESET}"
      echo -e "${BLACK}${BG_WHITE} • Monochromatic dark theme${RESET}"
      echo -e "${BLACK}${BG_WHITE} • Subtle gray accents${RESET}"
      echo -e "${BLACK}${BG_WHITE} • Clean minimalist design${RESET}"
      ;;
    "dark_pink")
      echo -e "${BOLD}${WHITE}${BG_MAGENTA} Dark Pink Theme ${RESET}"
      echo -e "${MAGENTA}${BG_BLACK} • Dark theme with pink accents${RESET}"
      echo -e "${MAGENTA}${BG_BLACK} • High contrast elements${RESET}"
      echo -e "${MAGENTA}${BG_BLACK} • Modern vibrant look${RESET}"
      ;;
    "dark_egg")
      echo -e "${BOLD}${BLACK}${BG_YELLOW} Dark Egg Theme ${RESET}"
      echo -e "${YELLOW}${BG_BLACK} • Dark theme with amber accents${RESET}"
      echo -e "${YELLOW}${BG_BLACK} • Warm color palette${RESET}"
      echo -e "${YELLOW}${BG_BLACK} • Subtle golden highlights${RESET}"
      ;;
    "apres_ski")
      echo -e "${BOLD}${BLACK}${BG_CYAN} Après Ski Theme ${RESET}"
      echo -e "${CYAN}${BG_BLACK} • Cool blue accents on dark${RESET}"
      echo -e "${CYAN}${BG_BLACK} • Winter-inspired palette${RESET}"
      echo -e "${CYAN}${BG_BLACK} • Refreshing visual style${RESET}"
      ;;
  esac
}

# Clear screen for better UI
clear

echo "🎨 ${BOLD}Sketchybar Theme Selector${RESET}"
echo "=============================="
echo

echo "Available themes:"
echo
echo "1) ${BOLD}Dark${RESET} (Default)"
preview_theme "dark"
echo
echo "2) ${BOLD}Dark Pink${RESET}"
preview_theme "dark_pink"
echo
echo "3) ${BOLD}Dark Egg${RESET}"
preview_theme "dark_egg"
echo
echo "4) ${BOLD}Après Ski${RESET}"
preview_theme "apres_ski"
echo

# Get user selection
read -p "Select theme (1-4): " choice

case $choice in
  1) 
    theme="dark"
    ;;
  2)
    theme="dark_pink"
    ;;
  3)
    theme="dark_egg"
    ;;
  4)
    theme="apres_ski"
    ;;
  *)
    echo "Invalid choice. Using default theme."
    theme="dark"
    ;;
esac

# Apply theme
echo "Applying $theme theme..."
"$CONFIG_DIR/sketchybar_config.sh" "$theme"
echo "Theme applied successfully!"