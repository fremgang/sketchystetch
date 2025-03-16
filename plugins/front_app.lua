#!/usr/bin/env lua

-- front_app.lua - Efficient front app detection with caching
-- Location: ~/.config/sketchybar/plugins/front_app.lua

local lfs = require("lfs")
local json = require("cjson")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local STATE_FILE = CACHE_DIR .. "/front_app_state.json"
local APP_ICONS = {
  ["Firefox"] = "􀼺",
  ["Safari"] = "􀤅",
  ["Cursor"] = "􀤃",
  ["Code"] = "􀤃",
  ["Terminal"] = "􀆍",
  ["Ghostty"] = "􀆍",
  ["iTerm2"] = "􀆍",
  ["Finder"] = "􀉋",
  ["Music"] = "􀑪",
  ["Messages"] = "􀌧",
  ["Mail"] = "􀍕",
  ["Notes"] = "􀓕",
  ["Zen Browser"] = "􀤆",
  ["Teams"] = "􀵏",
  ["Discord"] = "􀙯",
  ["Slack"] = "􀕮"
}

-- Helper functions
local function file_exists(path)
  local f = io.open(path, "r")
  if f then 
    f:close()
    return true 
  end
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

-- Ensure cache directory exists
lfs.mkdir(CACHE_DIR)

-- Get current app process info
local function get_frontmost_app()
  local script = [[
    tell application "System Events" to get name of first application process whose frontmost is true
  ]]
  
  local handle = io.popen("osascript -e '" .. script .. "'")
  local app_name = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  return app_name
end

-- Main function
local function update_front_app()
  -- Get current app name
  local current_app = get_frontmost_app()
  if not current_app or #current_app == 0 then
    return false
  end
  
  -- Check if app state has changed
  local state = read_json(STATE_FILE)
  if state and state.app == current_app then
    return false -- No change
  end
  
  -- Truncate long names efficiently
  local display_name = current_app
  if #display_name > 25 then
    display_name = string.sub(display_name, 1, 22) .. "..."
  end
  
  -- Find icon for the app
  local icon = APP_ICONS[current_app] or "􀟜"
  
  -- Store current state
  write_json(STATE_FILE, {app = current_app, time = os.time()})
  
  -- Update sketchybar
  os.execute(string.format(
    "sketchybar --set front_app icon='%s' label='%s'",
    icon, display_name
  ))
  
  return true
end

-- Run the update
update_front_app()