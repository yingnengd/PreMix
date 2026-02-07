-- =========================================================
-- MCP Auto Mix Engine
-- Responsibility Model (v1.1)
--
-- Changes from v1.0:
-- - Section-aware
-- - Stability-aware
-- - Still NO FX / NO automation
-- =========================================================

local U = require("mcp_utils")
local R = require("mcp_roles")
local S = require("mcp_stability")

local M = {}

------------------------------------------------------------
-- Role weights (unchanged philosophy)
------------------------------------------------------------

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

------------------------------------------------------------
-- Pressure models（与 v1.0 一致）
------------------------------------------------------------

local function vocal_pressure(a)
  if not a then return 0 end
  return U.clamp(
    U.norm(a.loudness or -24, -30, -14) * 0.4 +
    U.norm(a.presence or 0, 0.2, 0.8)   * 0.4 +
    U.norm(a.sibilance or 0, 0.2, 0.8)  * 0.2,
    0, 1
  )
end

local function music_pressure(a)
  if not a then return 0 end
  return U.clamp(
    U.norm(a.low_mid or 0, 0.3, 0.9)    * 0.45 +
    U.norm(a.presence or 0, 0.3, 0.9)   * 0.35 +
    U.norm(a.stereo_spread or 0.2, 0.9) * 0.20,
    0, 1
  )
end

------------------------------------------------------------
-- Core builders (v1.1)
------------------------------------------------------------

local function build(domain, roles, analysis, pressure_fn, weight_map)
  local results = {}
  local pressure = pressure_fn(analysis)
  if pressure <= 0 then return results end

  local section = _G.MCP_CURRENT_SECTION or "A"

  for _, info in ipairs(roles) do
    if info.type == domain then
      local w = weight_map[info.role] or 0
      if w > 0 then
        local raw = U.clamp(w * pressure, 0, 1)
        local stable = S.stabilize(info.track, raw, section)

        table.insert(results, {
          track        = info.track,
          name         = info.name,
          domain       = domain,
          role         = info.role,
          raw_score    = raw,
          stable_score = stable,
          section      = section
        })
      end
    end
  end

  table.sort(results, function(a, b)
    return a.stable_score > b.stable_score
  end)

  return results
end

function M.build_vocal(roles, analysis)
  return build("VOCAL", roles, analysis, vocal_pressure, VOCAL_ROLE_WEIGHT)
end

function M.build_music(roles, analysis)
  return build("MUSIC", roles, analysis, music_pressure, MUSIC_ROLE_WEIGHT)
end

return M
