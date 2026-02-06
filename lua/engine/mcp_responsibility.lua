-- =========================================================
-- MCP Auto Mix Engine
-- Responsibility Model (v1.0)
--
-- This module decides *which buses should yield* based on:
--   1. Bus roles (from mcp_roles)
--   2. Offline analysis facts (from Essentia)
--
-- IMPORTANT:
-- - No FX insertion here
-- - No parameter changes here
-- - Pure responsibility scoring
-- =========================================================

local U = require("mcp_utils")
local R = require("mcp_roles")

local M = {}

-- ---------------------------------------------------------
-- Responsibility weights (v1.0 frozen philosophy)
-- ---------------------------------------------------------

-- Higher value = more likely to be asked to move
local VOCAL_ROLE_WEIGHT = {
  PAD    = 1.00,
  HARM   = 0.75,
  DOUBLE = 0.55,
  FX     = 0.40
}

local MUSIC_ROLE_WEIGHT = {
  LOW   = 0.80,
  MID   = 0.65,
  HIGH  = 0.50,
  FX    = 0.40
}

-- ---------------------------------------------------------
-- Bus pressure models (analysis → 0..1 pressure)
-- ---------------------------------------------------------

local function vocal_pressure(analysis)
  if not analysis then return 0 end

  -- Expected fields (from analyze_bus.py):
  -- loudness, presence, sibilance, dynamic_complexity

  local loud_f = U.norm(analysis.loudness or -24, -30, -14)
  local pres_f = U.norm(analysis.presence or 0, 0.2, 0.8)
  local sib_f  = U.norm(analysis.sibilance or 0, 0.2, 0.8)

  -- Weighted vocal stress model
  local pressure =
      loud_f * 0.40 +
      pres_f  * 0.40 +
      sib_f   * 0.20

  return U.clamp(pressure, 0, 1)
end

local function music_pressure(analysis)
  if not analysis then return 0 end

  -- Expected fields:
  -- low_mid, presence, stereo_spread

  local low_f   = U.norm(analysis.low_mid or 0, 0.3, 0.9)
  local pres_f  = U.norm(analysis.presence or 0, 0.3, 0.9)
  local width_f = U.norm(analysis.stereo_spread or 0.2, 0.9)

  local pressure =
      low_f   * 0.45 +
      pres_f  * 0.35 +
      width_f * 0.20

  return U.clamp(pressure, 0, 1)
end

-- ---------------------------------------------------------
-- Core responsibility scoring
-- ---------------------------------------------------------

--- Build responsibility list for vocal-related buses
-- @param roles table (from mcp_roles.scan_project)
-- @param analysis table (vocal analysis)
-- @return table list of responsibility entries
function M.build_vocal(roles, analysis)
  local results = {}
  local pressure = vocal_pressure(analysis)

  if pressure <= 0 then return results end

  for _, info in ipairs(roles) do
    if info.type == "VOCAL" then
      local weight = VOCAL_ROLE_WEIGHT[info.role] or 0
      if weight > 0 then
        local score = U.clamp(weight * pressure, 0, 1)
        table.insert(results, {
          track  = info.track,
          name   = info.name,
          domain = "VOCAL",
          role   = info.role,
          score  = score
        })
      end
    end
  end

  table.sort(results, function(a, b)
    return a.score > b.score
  end)

  return results
end

--- Build responsibility list for music-related buses
-- @param roles table
-- @param analysis table (music analysis)
-- @return table list
function M.build_music(roles, analysis)
  local results = {}
  local pressure = music_pressure(analysis)

  if pressure <= 0 then return results end

  for _, info in ipairs(roles) do
    if info.type == "MUSIC" then
      local weight = MUSIC_ROLE_WEIGHT[info.role] or 0
      if weight > 0 then
        local score = U.clamp(weight * pressure, 0, 1)
        table.insert(results, {
          track  = info.track,
          name   = info.name,
          domain = "MUSIC",
          role   = info.role,
          score  = score
        })
      end
    end
  end

  table.sort(results, function(a, b)
    return a.score > b.score
  end)

  return results
end

return M
