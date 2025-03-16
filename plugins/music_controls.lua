#!/usr/bin/env lua

-- music_controls.lua - Advanced music controls with visualization
-- Location: ~/.config/sketchybar/plugins/music_controls.lua

local lfs = require("lfs")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local TMP_DIR = CACHE_DIR .. "/music"
local MODE = arg[1] or "status" -- prev, play, next, prev_click, play_click, next_click, status

-- Create cache directory
lfs.mkdir(CACHE_DIR)
lfs.mkdir(TMP_DIR)

-- Check if Music app is running
local function is_music_running()
  local handle = io.popen("pgrep -x Music")
  local result = handle:read("*a")
  handle:close()
  return result and #result > 0
end

-- Check if music is playing
local function get_player_state()
  if not is_music_running() then
    return "not_running"
  end
  
  local script = [[
    if application "Music" is running then
      tell application "Music"
        return player state as string
      end tell
    else
      return "not_running"
    end if
  ]]
  
  local handle = io.popen("osascript -e '" .. script .. "'")
  local state = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  return state
end

-- Get music info
local function get_music_info()
  if not is_music_running() then
    return nil
  end
  
  local script = [[
    if application "Music" is running then
      tell application "Music"
        if player state is playing or player state is paused then
          set trackName to name of current track
          set artistName to artist of current track
          set albumName to album of current track
          set trackDuration to duration of current track
          set trackPosition to player position
          set playerState to player state
          return trackName & "|" & artistName & "|" & albumName & "|" & 
                 trackDuration & "|" & trackPosition & "|" & playerState
        else
          return "not_playing"
        end if
      end tell
    else
      return "not_running"
    end if
  ]]
  
  local handle = io.popen("osascript -e '" .. script .. "'")
  local info = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  if info == "not_playing" or info == "not_running" then
    return nil
  end
  
  local parts = {}
  for part in string.gmatch(info, "[^|]+") do
    table.insert(parts, part)
  end
  
  if #parts < 6 then
    return nil
  end
  
  return {
    track = parts[1],
    artist = parts[2],
    album = parts[3],
    duration = tonumber(parts[4]) or 0,
    position = tonumber(parts[5]) or 0,
    state = parts[6]
  }
end

-- Control playback functions
local function play_pause()
  if not is_music_running() then return false end
  os.execute("osascript -e 'tell application \"Music\" to playpause'")
  return true
end

local function next_track()
  if not is_music_running() then return false end
  os.execute("osascript -e 'tell application \"Music\" to next track'")
  return true
end

local function prev_track()
  if not is_music_running() then return false end
  os.execute("osascript -e 'tell application \"Music\" to previous track'")
  return true
end

-- Update Music controls visibility
local function update_music_controls()
  local player_state = get_player_state()
  local is_active = player_state == "playing" or player_state == "paused"
  
  -- Show/hide controls based on state
  local drawing = is_active and "on" or "off"
  os.execute("sketchybar --set music.prev drawing=" .. drawing)
  os.execute("sketchybar --set music.play drawing=" .. drawing)
  os.execute("sketchybar --set music.next drawing=" .. drawing)
  os.execute("sketchybar --set music.info drawing=" .. drawing)
  os.execute("sketchybar --set music.album drawing=" .. drawing)
  
  if not is_active then return end
  
  -- Update play/pause button
  local play_icon = player_state == "playing" and "􀊆" or "􀊄"
  os.execute("sketchybar --set music.play icon='" .. play_icon .. "'")
  
  -- Trigger music info update
  os.execute("sketchybar --trigger music_change")
end

-- Handle control clicking
if MODE == "prev_click" then
  prev_track()
  os.execute("sleep 0.1") -- Give time for state to update
  update_music_controls()
elseif MODE == "play_click" then
  play_pause()
  os.execute("sleep 0.1") -- Give time for state to update
  update_music_controls()
elseif MODE == "next_click" then
  next_track()
  os.execute("sleep 0.1") -- Give time for state to update
  update_music_controls()
elseif MODE == "play" or MODE == "prev" or MODE == "next" then
  update_music_controls()
end