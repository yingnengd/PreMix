-- =========================================================
-- MCP Auto Mix Engine
-- Role Detection Module (v1.0)
--
-- This module classifies tracks and buses into semantic roles
-- based on the MCP bus architecture.
--
-- IMPORTANT:
-- - No audio analysis here
-- - No decision logic
-- - Pure structural classification
-- =========================================================

local r = reaper
local U = require("mcp_utils")

local M = {}

-- ---------------------------------------------------------
-- Role definitions (v1.0 fixed)
-- ---------------------------------------------------------

M.ROLES = {
  -- Protected / Target buses (never auto-modified)
  PROTECTED = {
    MCP_MASTER_BUS     = true,
    MCP_V_MASTER_BUS   = true,
    MCP_V_PRESENT_BUS  = true,
    MCP_MUSIC_BUS      = true
  },

  -- Vocal responsibility buses (can be modified)
  VOCAL_RESPONSIBILITY = {
    V_PAD_BUS     = "PAD",
    V_HARM_BUS    = "HARM",
    V_DOUBLE_BUS  = "DOUBLE",
    V_DELAY_BUS   = "FX",
    V_REVERB_BUS  = "FX"
  },

  -- Music responsibility buses (can be modified)
  MUSIC_RESPONSIBILITY = {
    MCP_LOW_INSTRUMENT_BUS   = "LOW",
    MCP_MID_INSTRUMENT_BUS   = "MID",
    MCP_HIGH_INSTRUMENT_BUS  = "HIGH",
    MCP_DELAY_BUS            = "FX",
    MCP_REVERB_BUS           = "FX"
  },

  -- Detection / reference buses (never modified)
  DETECTION = {
    MCP_V_DETECT_BUS = true
  }
}

-- ---------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------

local function get_track_name(track)
  if not track then return nil end
  local _, name = r.GetTrackName(track)
  return name
end

-- ---------------------------------------------------------
-- Public API
-- ---------------------------------------------------------

--- Classify a track into MCP role metadata
-- @param track MediaTrack
-- @return table role_info
function M.classify_track(track)
  local name = get_track_name(track)
  if not name then return nil end

  -- 1. Absolute protected buses
  if M.ROLES.PROTECTED[name] then
    return {
      track = track,
      name  = name,
      type  = "PROTECTED",
      role  = "TARGET"
    }
  end

  -- 2. Detection buses
  if M.ROLES.DETECTION[name] then
    return {
      track = track,
      name  = name,
      type  = "DETECT",
      role  = "REFERENCE"
    }
  end

  -- 3. Vocal responsibility buses
  local vocal_role = M.ROLES.VOCAL_RESPONSIBILITY[name]
  if vocal_role then
    return {
      track = track,
      name  = name,
      type  = "VOCAL",
      role  = vocal_role
    }
  end

  -- 4. Music responsibility buses
  local music_role = M.ROLES.MUSIC_RESPONSIBILITY[name]
  if music_role then
    return {
      track = track,
      name  = name,
      type  = "MUSIC",
      role  = music_role
    }
  end

  -- 5. Unclassified tracks (ignored by MCP v1.0)
  return {
    track = track,
    name  = name,
    type  = "OTHER",
    role  = "NONE"
  }
end

--- Scan all tracks in the project and classify them
-- @return table list of role_info
function M.scan_project()
  local results = {}
  local count = r.CountTracks(0)

  for i = 0, count - 1 do
    local tr = r.GetTrack(0, i)
    local info = M.classify_track(tr)
    if info then
      table.insert(results, info)
    end
  end

  return results
end

--- Filter tracks by category
-- @param roles table result of scan_project
-- @param type string ("VOCAL" | "MUSIC" | "PROTECTED" | "DETECT")
function M.filter_by_type(roles, type)
  local out = {}
  for _, rinfo in ipairs(roles) do
    if rinfo.type == type then
      table.insert(out, rinfo)
    end
  end
  return out
end

--- Convenience helpers

function M.get_vocal_responsibility_tracks(roles)
  return M.filter_by_type(roles, "VOCAL")
end

function M.get_music_responsibility_tracks(roles)
  return M.filter_by_type(roles, "MUSIC")
end

function M.get_protected_tracks(roles)
  return M.filter_by_type(roles, "PROTECTED")
end

return M
