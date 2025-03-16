#!/usr/bin/env lua

-- workspace_indicator.lua - Visual workspace indicator with animations
-- Location: ~/.config/sketchybar/plugins/workspace_indicator.lua

-- Get space ID from arguments
local space_id = arg[1]
if not space_id then
  os.exit(1)
end

-- Configuration
local ACTIVE_BG = "0x60404040"     -- Active workspace background
local ACTIVE_LABEL = "0xffdddddd"  -- Active workspace label
local INACTIVE_LABEL = "0xffa0a0a0"  -- Inactive workspace label
local CACHE_DIR = "/tmp/sketchybar_cache"

-- Get current space from environment or query aerospace
local function get_current_space()
  local space = os.getenv("FOCUSED_WORKSPACE") or os.getenv("space")
  
  if not space or space == "" then
    -- Query aerospace directly
    local handle = io.popen("aerospace list-workspaces --focused 2>/dev/null || echo 1")
    space = handle:read("*a"):gsub("%s+$", "")
    handle:close()
  end
  
  return space
end

-- Get all workspaces
local function get_all_workspaces()
  local handle = io.popen("aerospace list-workspaces --all 2>/dev/null || echo '1 2 3 4 5'")
  local workspaces = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  -- Parse into a table
  local result = {}
  for ws in string.gmatch(workspaces, "%S+") do
    table.insert(result, ws)
  end
  
  return result
end

-- Get windows on a specific workspace
local function get_windows_on_workspace(ws_id)
  local handle = io.popen("aerospace list-windows --workspace " .. ws_id .. " 2>/dev/null | wc -l")
  local count = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  return tonumber(count) or 0
end

-- Check if workspace has windows
local function workspace_has_windows(ws_id)
  return get_windows_on_workspace(ws_id) > 0
end

-- Main function to update workspace indicator
local function update_workspace_indicator()
  local current_space = get_current_space()
  local is_active = (current_space == space_id)
  local has_windows = workspace_has_windows(space_id)
  
  -- Define appearance based on state
  local bg_drawing = is_active and "on" or "off"
  local bg_color = ACTIVE_BG
  local label_color = is_active and ACTIVE_LABEL or INACTIVE_LABEL
  
  -- Special styling for workspaces with windows
  local label_style = ""
  if has_windows and not is_active then
    label_style = ":Bold"
  end
  
  -- Apply settings
  os.execute(string.format(
    "sketchybar --set space.%s background.drawing=%s background.color=%s label.color=%s label.font='SF Pro%s:12.0'",
    space_id, bg_drawing, bg_color, label_color, label_style
  ))
end

-- Run the update
update_workspace_indicator()