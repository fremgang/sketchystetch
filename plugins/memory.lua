#!/usr/bin/env lua

-- memory.lua - Memory usage monitor
-- Location: ~/.config/sketchybar/plugins/memory.lua

local lfs = require("lfs")
local json = require("cjson")

-- Configuration
local CACHE_DIR = "/tmp/sketchybar_cache"
local STATE_FILE = CACHE_DIR .. "/memory_state.json"
local THROTTLE_TIME = 3 -- seconds

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

-- Format memory size
local function format_size(bytes)
  bytes = bytes or 0
  
  if bytes >= 1073741824 then
    return string.format("%.1f GB", bytes / 1073741824)
  elseif bytes >= 1048576 then
    return string.format("%.1f MB", bytes / 1048576)
  elseif bytes >= 1024 then
    return string.format("%.1f KB", bytes / 1024)
  else
    return string.format("%d B", bytes)
  end
end

-- Get memory usage
local function get_memory_usage()
  local handle = io.popen("vm_stat")
  local vm_stat = handle:read("*a")
  handle:close()
  
  handle = io.popen("sysctl hw.memsize")
  local memsize = handle:read("*a")
  handle:close()
  
  -- Parse total memory
  local total_memory = tonumber(memsize:match("hw.memsize: (%d+)"))
  if not total_memory then return nil end
  
  -- Parse vm_stat output (page size is 4096 bytes on macOS)
  local page_size = 4096
  local metrics = {}
  
  for line in vm_stat:gmatch("[^\r\n]+") do
    local name, value = line:match("^(.+):%s+(%d+)")
    if name and value then
      metrics[name:gsub("%s+", "_")] = tonumber(value)
    end
  end
  
  if not metrics.Pages_free then return nil end
  
  -- Calculate memory usage
  local free_pages = metrics.Pages_free
  local active_pages = metrics.Pages_active
  local inactive_pages = metrics.Pages_inactive
  local speculative_pages = metrics.Pages_speculative or 0
  local wired_pages = metrics.Pages_wired_down
  
  local free_memory = (free_pages + inactive_pages) * page_size
  local used_memory = (active_pages + wired_pages) * page_size
  
  -- Account for compressed memory if available
  if metrics.Pages_occupied_by_compressor then
    used_memory = used_memory + (metrics.Pages_occupied_by_compressor * page_size)
  end
  
  local total_used = total_memory - free_memory
  local percentage = math.floor((total_used / total_memory) * 100)
  
  return {
    total = total_memory,
    used = total_used,
    free = free_memory,
    percentage = percentage,
    formatted_used = format_size(total_used),
    formatted_total = format_size(total_memory)
  }
end

-- Main function to update memory info
local function update_memory()
  -- Check throttling
  local state = read_json(STATE_FILE)
  local now = os.time()
  
  if state and (now - state.time) < THROTTLE_TIME then
    -- Re-use cached value
    os.execute(string.format(
      "sketchybar --set memory label='%d%% (%s)'",
      state.usage.percentage, state.usage.formatted_used
    ))
    return
  end
  
  -- Get fresh memory data
  local usage = get_memory_usage()
  if not usage then return end
  
  -- Save state
  write_json(STATE_FILE, {
    usage = usage,
    time = now
  })
  
  -- Update sketchybar
  os.execute(string.format(
    "sketchybar --set memory label='%d%% (%s)'",
    usage.percentage, usage.formatted_used
  ))
end

-- Run the update
update_memory()