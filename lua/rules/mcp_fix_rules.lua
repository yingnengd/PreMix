-- =========================================================
-- MCP Auto Mix Engine
-- Fix Rules (v1.0)
--
-- Translate responsibility score → mix intention
--
-- IMPORTANT:
-- - Plugin agnostic
-- - No FX index
-- - No DAW calls
-- - Semantic mix actions only
-- =========================================================

local U = require("engine.mcp_utils")

local M = {}

-- ---------------------------------------------------------
-- Thresholds (v1 philosophy)
-- ---------------------------------------------------------

local THRESHOLD = {
  LOW    = 0.30, -- ignore
  MEDIUM = 0.55, -- gentle yield
  HIGH   = 0.75  -- strong yield
}

-- ---------------------------------------------------------
-- Action builders (pure semantics)
-- ---------------------------------------------------------

local function reduce_presence(score)
  return {
    action = "reduce_presence",
    amount = U.clamp(score, 0, 1)
  }
end

local function reduce_low_mid(score)
  return {
    action = "reduce_low_mid",
    amount = U.clamp(score * 0.8, 0, 1)
  }
end

local function compress_dynamic(score)
  return {
    action = "compress_dynamic",
    amount = U.clamp(score, 0, 1)
  }
end

local function narrow_width(score)
  return {
    action = "narrow_width",
    amount = U.clamp(score * 0.7, 0, 1)
  }
end

-- ---------------------------------------------------------
-- Vocal domain rules
-- ---------------------------------------------------------

local function vocal_rule(entry)
  local s = entry.score
  if s < THRESHOLD.MEDIUM then return nil end

  if entry.role == "PAD" then
    return {
      reduce_presence(s),
      narrow_width(s)
    }

  elseif entry.role == "HARM" then
    return {
      reduce_presence(s * 0.8)
    }

  elseif entry.role == "DOUBLE" then
    return {
      compress_dynamic(s * 0.9)
    }

  elseif entry.role == "FX" then
    return {
      reduce_presence(s * 0.6)
    }
  end

  return nil
end

-- ---------------------------------------------------------
-- Music domain rules
-- ---------------------------------------------------------

local function music_rule(entry)
  local s = entry.score
  if s < THRESHOLD.MEDIUM then return nil end

  if entry.role == "LOW" then
    return {
      reduce_low_mid(s)
    }

  elseif entry.role == "MID" then
    return {
      reduce_presence(s * 0.8)
    }

  elseif entry.role == "HIGH" then
    return {
      reduce_presence(s * 0.6),
      narrow_width(s * 0.5)
    }

  elseif entry.role == "FX" then
    return {
      narrow_width(s)
    }
  end

  return nil
end

-- ---------------------------------------------------------
-- Public entry
-- ---------------------------------------------------------

--- Build fix actions from responsibility list
-- @param responsibilities table (from mcp_responsibility)
-- @return table list of { track, actions[] }
function M.build(responsibilities)
  local fixes = {}

  for _, entry in ipairs(responsibilities) do
    local actions = nil

    if entry.domain == "VOCAL" then
      actions = vocal_rule(entry)
    elseif entry.domain == "MUSIC" then
      actions = music_rule(entry)
    end

    if actions and #actions > 0 then
      table.insert(fixes, {
        track   = entry.track,
        name    = entry.name,
        domain  = entry.domain,
        role    = entry.role,
        score   = entry.score,
        actions = actions
      })
    end
  end

  return fixes
end

return M
