#!/usr/bin/env lua

-- datetime.lua - Efficient datetime display with caching
-- Location: ~/.config/sketchybar/plugins/datetime.lua

local lfs = require("lfs")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local CACHE_FILE = CACHE_DIR .. "/datetime"
local UPDATE_INTERVAL = 30 -- seconds

-- Create cache directory
lfs.mkdir(CACHE_DIR)

-- Helper function to read file
local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  
  local content = f:read("*all")
  f:close()
  
  return content
end

-- Helper function to write file
local function write_file(path, content)
  local f = io.open(path, "w")
  if not f then return false end
  
  f:write(content)
  f:close()
  
  return true
end

-- Format datetime string
local function format_datetime()
  local handle = io.popen("date +\"%H:%M · %a %d\"")
  local datetime = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  return datetime
end

-- Main function to update datetime
local function update_datetime()
  -- Check if cache exists and is recent
  local now = os.time()
  local last_update = tonumber(read_file(CACHE_FILE .. ".time") or "0")
  
  if (now - last_update) < UPDATE_INTERVAL then
    -- Use cached datetime
    local cached = read_file(CACHE_FILE)
    if cached then
      os.execute("sketchybar --set datetime label='" .. cached .. "'")
      return
    end
  end
  
  -- Format and update datetime
  local datetime = format_datetime()
  
  -- Cache the result
  write_file(CACHE_FILE, datetime)
  write_file(CACHE_FILE .. ".time", tostring(now))
  
  -- Update sketchybar
  os.execute("sketchybar --set datetime label='" .. datetime .. "'")
end

-- Run the update
update_datetime()