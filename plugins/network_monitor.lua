#!/usr/bin/env lua

-- network_monitor.lua - Advanced network monitoring with visualization
-- Location: ~/.config/sketchybar/plugins/network_monitor.lua

local lfs = require("lfs")
local json = require("cjson")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local STATE_FILE = CACHE_DIR .. "/network_state.json"
local HISTORY_FILE = CACHE_DIR .. "/network_history.json"
local THROTTLE_TIME = 2 -- seconds
local MAX_HISTORY = 100 -- data points to keep for graph
local RX_COLOR = "0x80ff9000" -- Download color (amber)
local TX_COLOR = "0x8000b4ff" -- Upload color (blue)

-- Create cache directory if needed
lfs.mkdir(CACHE_DIR)

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

-- Format speed with units
local function format_speed(bytes)
  if bytes > 1048576 then
    return string.format("%.1f MB/s", bytes / 1048576)
  elseif bytes > 1024 then
    return string.format("%.1f KB/s", bytes / 1024)
  else
    return string.format("%d B/s", bytes)
  end
end

-- Get network interface and stats
local function get_network_stats()
  -- Get default interface
  local handle = io.popen("route -n get default 2>/dev/null | grep interface | awk '{print $2}'")
  local interface = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  if not interface or #interface == 0 then
    interface = "en0" -- fallback
  end
  
  -- Get RX/TX bytes
  handle = io.popen("netstat -ibn | grep -e " .. interface .. " | head -n1")
  local netstat_data = handle:read("*a")
  handle:close()
  
  local rx_bytes, tx_bytes = 0, 0
  
  -- Parse netstat output
  for ibytes, obytes in string.gmatch(netstat_data, "(%d+)%s+(%d+)%s+") do
    rx_bytes, tx_bytes = tonumber(ibytes), tonumber(obytes)
    break
  end
  
  if not rx_bytes then
    -- Alternative parsing approach (different macOS versions)
    rx_bytes = tonumber(netstat_data:match("(%d+).-7.-"))
    tx_bytes = tonumber(netstat_data:match("(%d+).-10.-"))
  end
  
  return {
    interface = interface,
    rx_bytes = rx_bytes or 0,
    tx_bytes = tx_bytes or 0,
    time = os.time()
  }
end

-- Update network stats and generate graph data
local function update_network()
  -- Get current stats
  local current = get_network_stats()
  
  -- Check throttling
  local state = read_json(STATE_FILE)
  if state and (os.time() - state.time) < THROTTLE_TIME then
    return false -- Skip update due to throttling
  end
  
  -- Initialize or read history
  local history = read_json(HISTORY_FILE) or {rx = {}, tx = {}, max_value = 1}
  
  -- Calculate speeds
  local rx_speed, tx_speed = 0, 0
  
  if state then
    local time_diff = current.time - state.time
    if time_diff > 0 then
      rx_speed = (current.rx_bytes - state.rx_bytes) / time_diff
      tx_speed = (current.tx_bytes - state.tx_bytes) / time_diff
      
      -- Handle counter resets
      if rx_speed < 0 then rx_speed = current.rx_bytes / time_diff end
      if tx_speed < 0 then tx_speed = current.tx_bytes / time_diff end
    end
  end
  
  -- Update history
  table.insert(history.rx, rx_speed)
  table.insert(history.tx, tx_speed)
  
  -- Trim history to max length
  while #history.rx > MAX_HISTORY do
    table.remove(history.rx, 1)
    table.remove(history.tx, 1)
  end
  
  -- Find maximum value for scaling
  local max_value = 1
  for _, v in ipairs(history.rx) do
    if v > max_value then max_value = v end
  end
  for _, v in ipairs(history.tx) do
    if v > max_value then max_value = v end
  end
  
  -- Smooth maximum value (prevent graph scaling too quickly)
  if history.max_value then
    history.max_value = math.max(max_value, history.max_value * 0.7)
  else
    history.max_value = max_value
  end
  
  -- Save state and history
  write_json(STATE_FILE, current)
  write_json(HISTORY_FILE, history)
  
  -- Format output for display
  local rx_format = format_speed(rx_speed)
  local tx_format = format_speed(tx_speed)
  
  -- Update sketchybar
  os.execute(string.format(
    "sketchybar --set network.graph label=\"↓%s ↑%s\" graph.color=%s graph.fill_color=%s",
    rx_format, tx_format, RX_COLOR, TX_COLOR
  ))
  
  -- Update graph data
  local graph_points = {}
  for i = 1, #history.rx do
    -- Scale to 0-100 range based on maximum value
    local height = math.min(100, (history.rx[i] / history.max_value) * 100)
    table.insert(graph_points, height)
  end
  
  os.execute(string.format(
    "sketchybar --set network.graph graph.value=%d",
    table.concat(graph_points, ",")
  ))
  
  return true
end

-- Run the update
update_network()