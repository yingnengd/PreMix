-- =========================================================
-- MCP Auto Mix Engine
-- Apply FX / Gain Layer (v1.2)
--
-- Responsibility → Gentle, reversible actions
-- No automation, no plugin control
-- =========================================================

local r = reaper

local U  = require("mcp_utils")
local R  = require("mcp_roles")
local RES = require("mcp_responsibility")
local SC = require("mcp_sidechain_responsibility")

local M = {}

------------------------------------------------------------
-- Config (v1.2 frozen)
------------------------------------------------------------

-- Max trim change (dB)
local MAX_TRIM_DB = -2.5

-- Section multipliers (来自你已有 section detector)
local SECTION_GAIN = {
  A = 0.6,
  B = 0.8,
  VERSE = 0.6,
  PRECHORUS = 0.8,
  CHORUS = 1.0,
  FINAL = 1.0
}

------------------------------------------------------------
-- Utilities
------------------------------------------------------------

local function get_section_factor()
  local sec = _G.MCP_CURRENT_SECTION or "A"
  return SECTION_GAIN[sec] or 0.6
end

local function apply_track_trim(track, delta_db)
  if not track then return end

  local vol = r.GetMediaTrackInfo_Value(track, "D_VOL")
  local vol_db = 20 * math.log(vol, 10)

  local new_db = U.clamp(vol_db + delta_db, -24, 12)
  local new_vol = 10 ^ (new_db / 20)

  r.SetMediaTrackInfo_Value(track, "D_VOL", new_vol)
end

------------------------------------------------------------
-- Apply Vocal Responsibility (一次贴脸 + 汇总保护)
------------------------------------------------------------

function M.apply_vocal(roles, vocal_analysis)
  local list = RES.build_vocal(roles, vocal_analysis)
  if #list == 0 then return end

  local sec_factor = get_section_factor()

  for _, item in ipairs(list) do
    local trim_db =
      item.score * MAX_TRIM_DB * sec_factor

    apply_track_trim(item.track, trim_db)
  end
end

------------------------------------------------------------
-- Apply Sidechain Responsibility (v1.2 核心)
------------------------------------------------------------

function M.apply_sidechain(roles, vocal_analysis, music_analysis)
  if not vocal_analysis or not music_analysis then return end

  local sec_factor = get_section_factor()

  for _, info in ipairs(roles) do
    if info.type ~= "MUSIC" then goto continue end

    local duck =
      SC.compute(vocal_analysis, music_analysis, info.role)

    if duck >= 0.999 then goto continue end

    -- convert duck weight to dB trim
    local duck_db =
      20 * math.log(duck, 10)

    local final_db =
      U.clamp(duck_db * sec_factor, MAX_TRIM_DB, 0)

    apply_track_trim(info.track, final_db)

    ::continue::
  end
end

------------------------------------------------------------
-- Entry (called by auto_engine)
------------------------------------------------------------

function M.apply(context)
  -- context = {
  --   roles,
  --   analysis = {
  --     vocal = {},
  --     music = {}
  --   }
  -- }

  if not context or not context.roles then return end

  r.Undo_BeginBlock()

  M.apply_vocal(
    context.roles,
    context.analysis and context.analysis.vocal
  )

  M.apply_sidechain(
    context.roles,
    context.analysis and context.analysis.vocal,
    context.analysis and context.analysis.music
  )

  r.Undo_EndBlock(
    "MCP Auto Mix Engine v1.2 – Apply Responsibility",
    -1
  )
end

return M
