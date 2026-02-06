-- =========================================================
-- FX Index Map
-- Maps semantic controls -> plugin parameter indices
-- =========================================================

local M = {}

-- =========================
-- FabFilter
-- =========================
M["FabFilter Pro-Q 3"] = {
  PRESENCE_GAIN = 3,     -- 当前选中 band gain
  DYN_RANGE     = 15,
  DYN_THRESH    = 16,
  OUTPUT_GAIN  = 74
}

M["FabFilter Pro-C 2"] = {
  THRESHOLD = 0,
  RATIO     = 1,
  ATTACK    = 2,
  RELEASE   = 3,
  MIX       = 14
}

M["FabFilter Pro-DS"] = {
  THRESHOLD = 0,
  RANGE     = 2,
  MIX       = 10
}

M["FabFilter Saturn 2"] = {
  DRIVE = 0,
  MIX   = 17
}

-- =========================
-- Waves
-- =========================
M["Waves F6 Stereo"] = {
  BAND_GAIN = 7,
  DYN_RANGE = 11
}

M["Waves R-Comp"] = {
  THRESHOLD = 0,
  RATIO     = 1,
  ATTACK    = 2,
  RELEASE   = 3
}

-- =========================
-- REAPER Native
-- =========================
M["ReaEQ (Cockos)"] = {
  BAND_GAIN = 2
}

M["ReaComp (Cockos)"] = {
  THRESHOLD = 0,
  RATIO     = 1,
  ATTACK    = 2,
  RELEASE   = 3
}

return M
