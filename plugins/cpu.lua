#!/usr/bin/env lua

-- cpu.lua - CPU usage monitor
-- Location: ~/.config/sketchybar/plugins/cpu.lua

local lfs = require("lfs")
local json = require("cjson")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local STATE_FILE = CACHE_DIR .. "/cpu_state.json"
local THROTTLE_TIME = 2 -- seconds

-- Create cache directory
lfs.mkdir(CACHE_DIR)

-- Helper functions
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

-- Get CPU usage
local function get_cpu_usage()
  local handle = io.popen("top -l 1 -n 0 -s 0 | grep 'CPU usage'")
  local cpu_info = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  local user, system, idle = cpu_info:match("(%d+%.%d+)%% user, (%d+%.%d+)%% sys, (%d+%.%d+)%% idle")
  
  if not user then return nil end
  
  return {
    user = tonumber(user) or 0,
    system = tonumber(system) or 0,
    idle = tonumber(idle) or 0,
    total = (tonumber(user) or 0) + (tonumber(system) or 0)
  }
end

-- Main function to update CPU info
local function update_cpu()
  -- Check throttling
  local state = read_json(STATE_FILE)
  local now = os.time()
  
  if state and (now - state.time) < THROTTLE_TIME then
    -- Re-use cached value
    os.execute(string.format(
      "sketchybar --set cpu label='%d%%'",
      state.usage.total
    ))
    return
  end
  
  -- Get fresh CPU data
  local usage = get_cpu_usage()
  if not usage then return end
  
  -- Save state
  write_json(STATE_FILE, {
    usage = usage,
    time = now
  })
  
  -- Update sketchybar
  local cpu_icon
  if usage.total < 30 then
    cpu_icon = "􀫑"  -- Low CPU
  elseif usage.total < 70 then
    cpu_icon = "􀫓"  -- Medium CPU
  else
    cpu_icon = "􀫕"  -- High CPU
  end
  
  os.execute(string.format(
    "sketchybar --set cpu icon='%s' label='%d%%'",
    cpu_icon, usage.total
  ))
end

-- Run the update
update_cpu()