-- =========================================================
-- MCP Auto Mix Engine v2
-- Main Entry
-- =========================================================

local r = reaper

local RunAna = require("engine.mcp_run_analysis")
local Read   = require("engine.mcp_read_plan")
local Apply  = require("engine.mcp_apply_fx")
local Role   = require("engine.mcp_roles")

local M = {}

local function ensure_project()
  if r.CountTracks(0) == 0 then
    r.ShowMessageBox("No tracks in project", "MCP Auto Mix", 0)
    return false
  end
  return true
end

function M.run()
  if not ensure_project() then return end

  r.Undo_BeginBlock()
  r.PreventUIRefresh(1)

  -- 1️⃣ 扫描轨道角色
  local roles = Role.scan_project()
  if not roles then
    r.ShowMessageBox("No MCP roles found", "MCP Auto Mix", 0)
    goto finish
  end

  -- 2️⃣ 启动 Python 分析
  RunAna.run()

  -- 3️⃣ 读取修正计划
  local plan = Read.load()
  if not plan or not plan.issues then
    goto finish
  end

  -- 4️⃣ 执行修正
  Apply.apply(plan, roles)

  ::finish::
  r.PreventUIRefresh(-1)
  r.Undo_EndBlock("MCP Auto Mix Engine v2", -1)
end

return M
