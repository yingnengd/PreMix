-- =========================================================
-- FX Profiles
-- Define WHICH plugins are used for each role & domain
-- =========================================================

local M = {}

-- 当前使用的 Profile（可由 Action / UI 切换）
M.ACTIVE = "FABFILTER"  -- "REA" | "WAVES" | "FABFILTER"

-- ---------------------------------------------------------
-- Profiles
-- ---------------------------------------------------------

M.PROFILES = {

-- =========================
-- REAPER Native
-- =========================
REA = {
  VOCAL = {
    PRESENT_EQ = "ReaEQ (Cockos)",
    DYN_EQ     = "ReaXcomp (Cockos)",
    COMP       = "ReaComp (Cockos)",
    DEESS      = "ReaXcomp (Cockos)",
    SAT        = "JS: Saturation"
  },

  MUSIC = {
    EQ   = "ReaEQ (Cockos)",
    COMP = "ReaComp (Cockos)",
    SC   = "ReaComp (Cockos)"
  }
},

-- =========================
-- Waves
-- =========================
WAVES = {
  VOCAL = {
    PRESENT_EQ = "Waves F6 Stereo",
    DYN_EQ     = "Waves F6 Stereo",
    COMP       = "Waves R-Comp",
    DEESS      = "Waves Sibilance",
    SAT        = "Waves J37"
  },

  MUSIC = {
    EQ   = "Waves F6 Stereo",
    COMP = "Waves R-Comp",
    SC   = "Waves C6"
  }
},

-- =========================
-- FabFilter
-- =========================
FABFILTER = {
  VOCAL = {
    PRESENT_EQ = "FabFilter Pro-Q 3",
    DYN_EQ     = "FabFilter Pro-Q 3",
    COMP       = "FabFilter Pro-C 2",
    DEESS      = "FabFilter Pro-DS",
    SAT        = "FabFilter Saturn 2"
  },

  MUSIC = {
    EQ   = "FabFilter Pro-Q 3",
    COMP = "FabFilter Pro-C 2",
    SC   = "FabFilter Pro-Q 3"
  }
}

}

-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------

function M.get()
  return M.PROFILES[M.ACTIVE]
end

function M.set(name)
  if M.PROFILES[name] then
    M.ACTIVE = name
    return true
  end
  return false
end

return M
