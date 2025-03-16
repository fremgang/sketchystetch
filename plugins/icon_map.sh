#!/bin/bash
# ~/.config/sketchybar/icon_map.sh

__icon_map() {
  case "$1" in
    "Finder") icon_result="finder";;
    "Safari") icon_result="safari";;
    "Terminal") icon_result="terminal";;
    "Zen") icon_result="zen_browser";;
    *) icon_result="default";;
  esac
}