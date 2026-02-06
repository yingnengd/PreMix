-- =========================================================
-- MCP Auto Mix Engine
-- FX Profiles (v1.0)
--
-- Defines WHICH plugins are used for each semantic action.
-- Plugin names here must match REAPER FX browser names.
-- =========================================================

local M = {}

-- Active profile (can be changed by engine)
M.ACTIVE = "FABFILTER"  -- REA | WAVES | FABFILTER

-- ---------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------

M.PROFILES = {

-- =========================
-- REAPER Native
-- =========================
REA = {
  reduce_presence = {
    plugin = "ReaEQ (Cockos)",
    type   = "EQ"
  },

  reduce_low_mid = {
    plugin = "ReaEQ (Cockos)",
    type   = "EQ"
  },

  compress_dynamic = {
    plugin = "ReaComp (Cockos)",
    type   = "COMP"
  },

  narrow_width = {
    plugin = "JS: Stereo Width",
    type   = "WIDTH"
  }
},

-- =========================
-- Waves
-- =========================
WAVES = {
  reduce_presence = {
    plugin = "Waves F6 Stereo",
    type   = "DYN_EQ"
  },

  reduce_low_mid = {
    plugin = "Waves F6 Stereo",
    type   = "DYN_EQ"
  },

  compress_dynamic = {
    plugin = "Waves R-Comp",
    type   = "COMP"
  },

  narrow_width = {
    plugin = "Waves S1 Stereo Imager",
    type   = "WIDTH"
  }
},

-- =========================
-- FabFilter
-- =========================
FABFILTER = {
  reduce_presence = {
    plugin = "FabFilter Pro-Q 3",
    type   = "DYN_EQ"
  },

  reduce_low_mid = {
    plugin = "FabFilter Pro-Q 3",
    type   = "DYN_EQ"
  },

  compress_dynamic = {
    plugin = "FabFilter Pro-C 2",
    type   = "COMP"
  },

  narrow_width = {
    plugin = "FabFilter Pro-Q 3",
    type   = "WIDTH"
  }
}

}

-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------

function M.get(action)
  local profile = M.PROFILES[M.ACTIVE]
  return profile and profile[action]
end

function M.set(profile)
  if M.PROFILES[profile] then
    M.ACTIVE = profile
    return true
  end
  return false
end

return M
