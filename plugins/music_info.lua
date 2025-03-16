#!/usr/bin/env lua

-- music_info.lua - High performance music info with caching
-- Location: ~/.config/sketchybar/plugins/music_info.lua

local lfs = require("lfs")
local json = require("cjson")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local TMP_DIR = CACHE_DIR .. "/music"
local STATE_FILE = TMP_DIR .. "/music_state.json"

-- Create cache directories
lfs.mkdir(CACHE_DIR)
lfs.mkdir(TMP_DIR)

-- Helper functions
local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close() return true end
  return false
end

local function write_json(path, data)
  local f = io.open(path, "w")
  if f then
    f:write(json.encode(data))
    f:close()
    return true
  end
  return false
end

local function read_json(path)
  local f = io.open(path, "r")
  if not f then return nil end
  
  local content = f:read("*all")
  f:close()
  
  if content and #content > 0 then
    local success, result = pcall(json.decode, content)
    if success then return result end
  end
  
  return nil
end

-- Check if Music app is running
local function is_music_running()
  local handle = io.popen("pgrep -x Music")
  local result = handle:read("*a")
  handle:close()
  return result and #result > 0
end

-- Get music information with caching
local function get_music_info()
  -- Check if Music is running first (fast check)
  if not is_music_running() then
    os.execute("sketchybar --set music.info drawing=off")
    os.execute("sketchybar --set music.album drawing=off")
    return nil
  end
  
  -- Check state file for recent updates
  local state = read_json(STATE_FILE)
  local current_time = os.time()
  
  if state and (current_time - state.time) < 2 then
    -- Use cached data if recent
    return state
  end
  
  -- Get new data with a single osascript call for efficiency
  local script = [[
    if application "Music" is running then
      tell application "Music"
        if player state is playing or player state is paused then
          set trackName to name of current track
          set artistName to artist of current track
          set albumName to album of current track
          set playerState to player state
          return trackName & "|" & artistName & "|" & albumName & "|" & playerState
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
    os.execute("sketchybar --set music.info drawing=off")
    os.execute("sketchybar --set music.album drawing=off")
    return nil
  end
  
  -- Parse music information
  local track, artist, album, player_state = info:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
  
  if not track then
    os.execute("sketchybar --set music.info drawing=off")
    os.execute("sketchybar --set music.album drawing=off")
    return nil
  end
  
  -- Create state object
  local music_state = {
    track = track,
    artist = artist,
    album = album,
    state = player_state,
    time = current_time
  }
  
  -- Save state
  write_json(STATE_FILE, music_state)
  
  return music_state
end

-- Format track info with truncation
local function format_track_info(info)
  if not info then return "Not Playing" end
  
  local track = info.track
  local artist = info.artist
  
  -- Truncate
  if #track > 30 then track = string.sub(track, 1, 27) .. "..." end
  if #artist > 18 then artist = string.sub(artist, 1, 15) .. "..." end
  
  return track .. " — " .. artist
end

-- Main function
local function update_music_info()
  local info = get_music_info()
  
  if not info then return end
  
  -- Set formatted track info
  local formatted = format_track_info(info)
  os.execute(string.format(
    "sketchybar --set music.info label='%s' drawing=on",
    formatted:gsub("'", "\\'") -- Escape single quotes
  ))
  
  -- Trigger album art update
  os.execute("sketchybar --set music.album drawing=on")
end

-- Run update
update_music_info()