-- =========================================================
-- MCP Auto Mix Engine
-- FX Apply Engine (v1.0)
--
-- Translates semantic mix actions into real plugin parameters
-- using fx_profiles + fx_index_map.
--
-- RULES:
-- - No fades
-- - No envelopes
-- - Plugin-internal control only
-- =========================================================

local r = reaper

local U       = require("engine.mcp_utils")
local FXP     = require("fx.fx_profiles")
local INDEX   = require("fx.fx_index_map")

local M = {}

-- ---------------------------------------------------------
-- Internal helpers
-- ---------------------------------------------------------

local function ensure_fx(track, fx_name)
  return r.TrackFX_AddByName(track, fx_name, false, 1)
end

local function set_param(track, fx, param, value)
  if fx < 0 then return end
  r.TrackFX_SetParamNormalized(track, fx, param, U.clamp(value, 0, 1))
end

-- ---------------------------------------------------------
-- Action implementations
-- ---------------------------------------------------------

local function apply_reduce_presence(track, amount)
  local cfg = FXP.get("reduce_presence")
  if not cfg then return end

  local fx = ensure_fx(track, cfg.plugin)
  local map = INDEX[cfg.plugin]
  if not map then return end

  if cfg.type == "EQ" or cfg.type == "DYN_EQ" then
    set_param(track, fx, map.BAND_GAIN, 0.5 - amount * 0.2)
  end
end

local function apply_reduce_low_mid(track, amount)
  local cfg = FXP.get("reduce_low_mid")
  if not cfg then return end

  local fx = ensure_fx(track, cfg.plugin)
  local map = INDEX[cfg.plugin]
  if not map then return end

  set_param(track, fx, map.BAND_GAIN, 0.5 - amount * 0.25)
end

local function apply_compress_dynamic(track, amount)
  local cfg = FXP.get("compress_dynamic")
  if not cfg then return end

  local fx = ensure_fx(track, cfg.plugin)
  local map = INDEX[cfg.plugin]
  if not map then return end

  set_param(track, fx, map.RATIO, amount)
end

local function apply_narrow_width(track, amount)
  local cfg = FXP.get("narrow_width")
  if not cfg then return end

  local fx = ensure_fx(track, cfg.plugin)
  local map = INDEX[cfg.plugin]
  if not map then return end

  set_param(track, fx, map.WIDTH or map.BAND_GAIN, 0.5 - amount * 0.3)
end

-- ---------------------------------------------------------
-- Dispatcher
-- ---------------------------------------------------------

function M.apply(fixes)
  for _, fix in ipairs(fixes or {}) do
    if U.track_has_flag(fix.track, "fx_applied") then goto continue end

    for _, act in ipairs(fix.actions) do
      if act.action == "reduce_presence" then
        apply_reduce_presence(fix.track, act.amount)

      elseif act.action == "reduce_low_mid" then
        apply_reduce_low_mid(fix.track, act.amount)

      elseif act.action == "compress_dynamic" then
        apply_compress_dynamic(fix.track, act.amount)

      elseif act.action == "narrow_width" then
        apply_narrow_width(fix.track, act.amount)
      end
    end

    U.track_set_flag(fix.track, "fx_applied", true)
    ::continue::
  end
end

return M
