local json = require("json")
local M = {}

local FIX_PLAN =
  "/ABS/PATH/mcp-auto-mix-engine/exchange/fix_plan.json"

function M.load()
  local f = io.open(FIX_PLAN, "r")
  if not f then return nil end

  local content = f:read("*a")
  f:close()

  return json.decode(content)
end

return M
