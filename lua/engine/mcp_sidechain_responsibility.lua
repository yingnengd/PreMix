-- =========================================================
-- MCP Auto Mix Engine
-- Sidechain Responsibility (v1.2)
--
-- Purpose:
--   Decide HOW MUCH a target bus should yield
--   when a dominant bus (e.g. Vocal) is strong
--
-- Output:
--   duck_weight ∈ [0.7 .. 1.0]
-- =========================================================

local U = require("mcp_utils")
local M = {}

------------------------------------------------------------
-- Config (frozen v1.2)
------------------------------------------------------------

-- how dominant the source must be to trigger yielding
local DOMINANCE_THRESHOLD = 0.55

-- max yielding strength
local MAX_DUCK = 0.30   -- 30%

-- per-role sensitivity (who yields more)
local ROLE_YIELD = {
  MUSIC = 1.00,
  PAD   = 1.20,
  FX    = 1.30,
  BGV   = 0.80,
  BASS  = 0.60,
  DRUMS = 0.50
}

------------------------------------------------------------
-- Utilities
------------------------------------------------------------

local function get_presence(analysis)
  if not analysis then return 0 end
  return analysis.presence or 0
end

local function role_factor(role)
  return ROLE_YIELD[role] or 1.0
end

------------------------------------------------------------
-- Core logic
------------------------------------------------------------

--- Compute ducking responsibility
-- @param source_analysis table (dominant bus, e.g. vocal)
-- @param target_analysis table (music / fx / pad)
-- @param target_role string
-- @return number duck_weight
function M.compute(source_analysis, target_analysis, target_role)
  if not source_analysis or not target_analysis then
    return 1.0
  end

  local src_p = get_presence(source_analysis)
  local tgt_p = get_presence(target_analysis)

  -- if source is not dominant enough → no yield
  if src_p < DOMINANCE_THRESHOLD then
    return 1.0
  end

  -- relative dominance (not absolute loudness)
  local dominance = U.clamp(src_p - tgt_p, 0, 1)

  local yield_strength =
      dominance * MAX_DUCK * role_factor(target_role)

  return U.clamp(1.0 - yield_strength, 0.7, 1.0)
end

return M
