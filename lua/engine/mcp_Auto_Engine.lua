-- =========================================================
-- MCP Auto Mix Engine
-- Main Entry (v1.0 SAFE)
--
-- One-click automatic mix balancing based on responsibility model
-- =========================================================

local r = reaper

local U    = require("engine.mcp_utils")
local Role = require("engine.mcp_roles")
local Ana  = require("engine.mcp_read_analysis")
local Resp = require("engine.mcp_responsibility")
local Rule = require("rules.mcp_fix_rules")
local FX   = require("engine.mcp_apply_fx")

local M = {}

------------------------------------------------------------
-- Safety checks
------------------------------------------------------------

local function ensure_project()
  if r.CountTracks(0) == 0 then
    r.ShowMessageBox("No tracks in project", "MCP Auto Mix", 0)
    return false
  end
  return true
end

------------------------------------------------------------
-- Cleanup helper（关键）
------------------------------------------------------------

local function cleanup()
  r.PreventUIRefresh(-1)
  r.Undo_EndBlock("MCP Auto Mix Engine v1.0", -1)
end

------------------------------------------------------------
-- Core execution
------------------------------------------------------------

function M.run()
  if not ensure_project() then return end

  r.Undo_BeginBlock()
  r.PreventUIRefresh(1)

  ----------------------------------------------------------
  -- 1. Scan roles
  ----------------------------------------------------------
  local roles = Role.scan_project()
  if not roles or #roles == 0 then
    r.ShowMessageBox("No MCP buses detected", "MCP Auto Mix", 0)
    cleanup()
    return
  end

  ----------------------------------------------------------
  -- 2. Read analysis results
  ----------------------------------------------------------
  local analysis = Ana.read_all()
  if not analysis then
    cleanup()
    return
  end

  ----------------------------------------------------------
  -- 3. Build responsibilities
  ----------------------------------------------------------
  local vocal_resp = Resp.build_vocal(roles, analysis.VOCAL)
  local music_resp = Resp.build_music(roles, analysis.MUSIC)

  local responsibilities = {}
  for _, v in ipairs(vocal_resp) do responsibilities[#responsibilities+1] = v end
  for _, m in ipairs(music_resp) do responsibilities[#responsibilities+1] = m end

  if #responsibilities == 0 then
    cleanup()
    return
  end

  ----------------------------------------------------------
  -- 4. Build fix actions
  ----------------------------------------------------------
  local fixes = Rule.build(responsibilities)
  if not fixes or #fixes == 0 then
    cleanup()
    return
  end

  ----------------------------------------------------------
  -- 5. Apply FX
  ----------------------------------------------------------
  FX.apply(fixes)

  ----------------------------------------------------------
  -- Finish
  ----------------------------------------------------------
  cleanup()
end

return M
