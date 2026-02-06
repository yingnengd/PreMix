-- =========================================================
-- MCP Auto Mix Engine
-- Utility Functions (v1.0)
--
-- This module contains ONLY stable, side-effect-safe helpers.
-- No mix logic, no rules, no analysis.
-- =========================================================

local r = reaper
local M = {}

-- ---------------------------------------------------------
-- Math helpers
-- ---------------------------------------------------------

--- Clamp a value between min and max
-- @param v number
-- @param min number
-- @param max number
-- @return number
function M.clamp(v, min, max)
  if v < min then return min end
  if v > max then return max end
  return v
end

--- Normalize a value to 0..1 given min/max
-- Safe against zero-range
function M.norm(v, min, max)
  if max <= min then return 0 end
  return M.clamp((v - min) / (max - min), 0, 1)
end

-- ---------------------------------------------------------
-- Undo helpers
-- ---------------------------------------------------------

function M.undo_begin(name)
  r.Undo_BeginBlock()
  if name then
    r.PreventUIRefresh(1)
  end
end

function M.undo_end(name)
  r.PreventUIRefresh(-1)
  r.Undo_EndBlock(name or "MCP Auto Mix", -1)
end

-- ---------------------------------------------------------
-- Track / Project flags (non-destructive state)
-- ---------------------------------------------------------

local EXT_NS = "MCP"

--- Check a boolean flag on a track
function M.track_has_flag(track, key)
  if not track then return false end
  local ok, val = r.GetSetMediaTrackInfo_String(track, "P_EXT:"..EXT_NS..":"..key, "", false)
  return ok and val == "1"
end

--- Set a boolean flag on a track
function M.track_set_flag(track, key, value)
  if not track then return end
  r.GetSetMediaTrackInfo_String(track, "P_EXT:"..EXT_NS..":"..key, value and "1" or "0", true)
end

--- Clear a boolean flag on a track
function M.track_clear_flag(track, key)
  if not track then return end
  r.GetSetMediaTrackInfo_String(track, "P_EXT:"..EXT_NS..":"..key, "", true)
end

-- ---------------------------------------------------------
-- Track lookup helpers
-- ---------------------------------------------------------

--- Find a track by exact name
-- Returns first match or nil
function M.find_track_by_name(name)
  local cnt = r.CountTracks(0)
  for i = 0, cnt - 1 do
    local tr = r.GetTrack(0, i)
    local _, tr_name = r.GetTrackName(tr)
    if tr_name == name then
      return tr
    end
  end
  return nil
end

--- Check if a track name matches any in a set
function M.name_in_set(name, set)
  if not name or not set then return false end
  return set[name] == true
end

-- ---------------------------------------------------------
-- FX helpers (safe, index-stable)
-- ---------------------------------------------------------

--- Ensure an FX exists on a track (by name)
-- Returns fx index
function M.ensure_fx(track, fx_name)
  if not track or not fx_name then return -1 end
  local fx = r.TrackFX_AddByName(track, fx_name, false, 1)
  return fx
end

--- Set FX parameter safely (normalized 0..1)
function M.safe_set_param(track, fx, param, value)
  if not track or fx < 0 or param < 0 then return end
  r.TrackFX_SetParamNormalized(track, fx, param, M.clamp(value, 0, 1))
end

-- ---------------------------------------------------------
-- Logging (optional, non-intrusive)
-- ---------------------------------------------------------

function M.log(msg)
  r.ShowConsoleMsg(tostring(msg) .. "\n")
end

return M
