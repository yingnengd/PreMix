local r = reaper
local M = {}

-- ⚠️ 你自己的 Conda Python
local PYTHON = "/Users/zideng/miniconda3/envs/mcp/bin/python"

-- Python 入口
local SCRIPT = "/ABS/PATH/mcp-auto-mix-engine/analysis/analyze_bus.py"

function M.run()
  local cmd = string.format('"%s" "%s"', PYTHON, SCRIPT)
  r.ExecProcess(cmd, 0)
end

return M
