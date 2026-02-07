-- =========================================================
-- MCP Auto Mix Engine
-- FX Profiles Matrix (v1.2)
--
-- Purpose:
--   Define WHICH plugin family is used for WHICH responsibility
--   This file NEVER sets parameter values or indices.
--
-- Design rules:
--   - Plugin-agnostic logic lives elsewhere
--   - Index mapping lives in fx_index_map.lua
--   - This file only answers: "use WHAT for WHICH job"
-- =========================================================

local M = {}

------------------------------------------------------------
-- Active profile selector
------------------------------------------------------------

-- Available profiles:
--   "REAPER" | "FABFILTER" | "WAVES"
M.ACTIVE = "FABFILTER"

------------------------------------------------------------
-- Profile definitions
------------------------------------------------------------

M.PROFILES = {

-- =========================================================
-- REAPER Native (Safe / Zero Dependency)
-- =========================================================
REAPER = {
  VOCAL = {
    CORE_EQ      = "ReaEQ (Cockos)",
    SUPPORT_EQ   = "ReaEQ (Cockos)",
    COMP         = "ReaComp (Cockos)",
    DEESS        = "ReaXcomp (Cockos)",
    WIDTH        = "JS: Stereo Width"
  },

  MUSIC = {
    BUS_EQ       = "ReaEQ (Cockos)",
    BUS_COMP     = "ReaComp (Cockos)",
    WIDTH        = "JS: Stereo Width"
  }
},

-- =========================================================
-- FabFilter Suite (Modern / Transparent)
-- =========================================================
FABFILTER = {
  VOCAL = {
    CORE_EQ      = "FabFilter Pro-Q 3",
    SUPPORT_EQ   = "FabFilter Pro-Q 3",
    COMP         = "FabFilter Pro-C 2",
    DEESS        = "FabFilter Pro-DS",
    WIDTH        = "FabFilter Pro-Q 3"
  },

  MUSIC = {
    BUS_EQ       = "FabFilter Pro-Q 3",
    BUS_COMP     = "FabFilter Pro-C 2",
    WIDTH        = "FabFilter Pro-Q 3"
  }
},

-- =========================================================
-- Waves Suite (Character / Commercial)
-- =========================================================
WAVES = {
  VOCAL = {
    CORE_EQ      = "Waves Scheps 73",
    SUPPORT_EQ   = "Waves F6 Stereo",
    COMP         = "Waves R-Comp",
    DEESS        = "Waves Sibilance",
    WIDTH        = "Waves S1 Stereo Imager"
  },

  MUSIC = {
    BUS_EQ       = "Waves F6 Stereo",
    BUS_COMP     = "Waves R-Comp",
    WIDTH        = "Waves S1 Stereo Imager"
  }
}

}

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

--- Get active profile table
function M.get()
  return M.PROFILES[M.ACTIVE]
end

--- Set active profile
function M.set(profile)
  if M.PROFILES[profile] then
    M.ACTIVE = profile
    return true
  end
  return false
end

--- Get plugin name by domain / role
-- @param domain string "VOCAL" | "MUSIC"
-- @param key string (e.g. CORE_EQ, BUS_COMP)
function M.plugin(domain, key)
  local p = M.PROFILES[M.ACTIVE]
  if not p or not p[domain] then return nil end
  return p[domain][key]
end

return M
