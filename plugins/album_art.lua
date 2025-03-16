#!/usr/bin/env lua

-- album_art.lua - Extract and display album artwork
-- Location: ~/.config/sketchybar/plugins/album_art.lua

local lfs = require("lfs")
local json = require("cjson")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local TMP_DIR = CACHE_DIR .. "/music"
local ART_FILE = TMP_DIR .. "/current_artwork.jpg"
local STATE_FILE = TMP_DIR .. "/album_state.json"

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

-- Get current album information
local function get_album_info()
  if not is_music_running() then return nil end
  
  local script = [[
    if application "Music" is running then
      tell application "Music"
        if player state is playing or player state is paused then
          set albumName to album of current track
          set trackId to database ID of current track
          return albumName & "|" & trackId
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
  
  local album, track_id = info:match("([^|]+)|([^|]+)")
  
  return {
    album = album,
    track_id = track_id
  }
end

-- Extract album artwork
local function extract_album_art()
  if not is_music_running() then return false end
  
  -- Check if art is already cached
  local album_info = get_album_info()
  if not album_info then return false end
  
  -- Check state file for recent extractions of the same album
  local state = read_json(STATE_FILE)
  if state and state.track_id == album_info.track_id and file_exists(ART_FILE) then
    -- Use cached artwork
    return true
  end
  
  -- Extract artwork using osascript
  local script = [[
    tell application "Music"
      if player state is playing or player state is paused then
        set currentTrack to current track
        set artworkData to artwork 1 of currentTrack
        set albumArt to raw data of artworkData
        return albumArt
      end if
    end tell
  ]]
  
  local succeeded = os.execute(string.format([[
    osascript -e '
      tell application "Music"
        if player state is playing or player state is paused then
          try
            tell artwork 1 of current track
              set srcBytes to raw data
              if format is «class PNG » then
                set ext to ".png"
              else
                set ext to ".jpg"
              end if
            end tell
            
            set fileName to "%s"
            -- write to file
            set outFile to open for access file fileName with write permission
            -- truncate the file
            set eof outFile to 0
            -- write the image bytes to the file
            write srcBytes to outFile
            close access outFile
            return "true"
          on error errMsg
            return "false: " & errMsg
          end try
        end if
      end tell'
    ]], ART_FILE))
  
  if succeeded then
    -- Save state
    write_json(STATE_FILE, album_info)
    return true
  end
  
  return false
end

-- Update the album art display
local function update_album_art()
  local has_art = extract_album_art()
  
  if has_art then
    os.execute(string.format(
      "sketchybar --set music.album background.image=%s background.image.drawing=on background.drawing=on",
      ART_FILE
    ))
    
    -- Position the album art next to the music.info item
    os.execute(
      "sketchybar --set music.album position=left-of --set music.album associated_space=music.info"
    )
  else
    os.execute("sketchybar --set music.album background.image.drawing=off background.drawing=off")
  end
end

-- Run the update
update_album_art()