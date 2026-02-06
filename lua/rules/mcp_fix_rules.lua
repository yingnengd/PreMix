-- =========================================================
-- MCP Auto Mix Engine
-- Fix Rules (v1.1)
--
-- Plugin-agnostic
-- Section-aware
-- Uses stable_score ONLY
-- =========================================================

local M = {}

------------------------------------------------------------
-- Thresholds
------------------------------------------------------------

local T = {
  LOW  = 0.25,
  MID  = 0.45,
  HIGH = 0.70
}

------------------------------------------------------------
-- Rule evaluation
------------------------------------------------------------

function M.evaluate(entry)
  local s = entry.stable_score
  local role = entry.role
  local domain = entry.domain

  if s < T.LOW then
    return nil
  end

  -- Vocal support tracks yield first
  if domain == "VOCAL" then
    if role == "PAD" or role == "HARM" then
      return {
        action = "REDUCE_PRESENCE",
        amount = s
      }
    end
    if role == "DOUBLE" then
      return {
        action = "TRIM_GAIN",
        amount = s * 0.6
      }
    end
  end

  -- Music buses yield under vocal pressure
  if domain == "MUSIC" then
    if role == "MID" or role == "HIGH" then
      return {
        action = "DUCK_MID",
        amount = s
      }
    end
  end

  return nil
end

return M
