-- =========================================================
-- MCP Auto Mix Engine
-- FX Index Map (v1.0)
--
-- Centralized mapping between semantic controls and
-- real plugin parameter indices.
--
-- IMPORTANT RULES:
-- - This is the ONLY file that knows parameter indices
-- - No mix logic here
-- - No DAW logic here
-- =========================================================

local M = {}

-- =========================================================
-- REAPER Native Plugins
-- =========================================================

-- -------------------------
-- ReaEQ (Cockos)
-- -------------------------
-- Assumptions:
-- Band 3 = Presence band (2–5 kHz typical)
-- Param layout: [Freq, Gain, Q, Type, Enabled] per band

M["ReaEQ (Cockos)"] = {
  BAND_GAIN = 2,   -- Gain of selected band
  BAND_FREQ = 1,
  BAND_Q    = 3
}

-- -------------------------
-- ReaComp (Cockos)
-- -------------------------

M["ReaComp (Cockos)"] = {
  THRESHOLD = 0,
  RATIO     = 1,
  ATTACK    = 2,
  RELEASE   = 3,
  KNEE      = 4,
  MAKEUP    = 9
}

-- =========================================================
-- FabFilter Plugins
-- =========================================================

-- -------------------------
-- FabFilter Pro-Q 3
-- -------------------------
-- Notes:
-- - MCP assumes "last touched band" workflow
-- - Dynamic EQ uses Dynamic Range / Threshold

M["FabFilter Pro-Q 3"] = {
  BAND_FREQ      = 2,
  BAND_GAIN      = 3,
  BAND_Q         = 7,
  DYN_RANGE      = 15,
  DYN_THRESHOLD  = 16,
  OUTPUT_GAIN    = 74
}

-- -------------------------
-- FabFilter Pro-C 2
-- -------------------------

M["FabFilter Pro-C 2"] = {
  THRESHOLD = 0,
  RATIO     = 1,
  ATTACK    = 2,
  RELEASE   = 3,
  KNEE      = 4,
  MIX       = 14
}

-- -------------------------
-- FabFilter Pro-DS
-- -------------------------

M["FabFilter Pro-DS"] = {
  THRESHOLD = 0,
  RANGE     = 2,
  MIX       = 10
}

-- -------------------------
-- FabFilter Saturn 2
-- -------------------------
-- MCP uses Band 1 only (broadband saturation)

M["FabFilter Saturn 2"] = {
  DRIVE = 11,   -- Band 1 Drive
  MIX   = 17
}

-- =========================================================
-- Waves Plugins
-- =========================================================

-- -------------------------
-- Waves F6 Stereo
-- -------------------------
-- Assumes Band 3 = Presence / Vocal focus

M["Waves F6 Stereo"] = {
  BAND_GAIN = 7,
  DYN_RANGE = 11,
  THRESHOLD = 9
}

-- -------------------------
-- Waves R-Comp
-- -------------------------

M["Waves R-Comp"] = {
  THRESHOLD = 0,
  RATIO     = 1,
  ATTACK    = 2,
  RELEASE   = 3,
  MIX       = 10
}

-- -------------------------
-- Waves CLA-76
-- -------------------------

M["Waves CLA-76"] = {
  INPUT   = 2,
  OUTPUT  = 3,
  ATTACK  = 4,
  RELEASE = 5,
  RATIO   = 6,
  MIX     = 11
}

-- -------------------------
-- Waves Scheps 73
-- -------------------------
-- Used mainly for tone shaping (NOT corrective EQ)

M["Waves Scheps 73"] = {
  PREAMP_GAIN = 2,
  HIGH_GAIN   = 6,
  MID_GAIN    = 9,
  LOW_GAIN    = 12
}

-- -------------------------
-- Waves NLS Channel
-- -------------------------
-- MCP uses Drive + Trim only

M["Waves NLS Channel"] = {
  DRIVE = 44,
  TRIM  = 5
}

-- =========================================================
-- Width / Utility
-- =========================================================

M["JS: Stereo Width"] = {
  WIDTH = 0
}

return M
