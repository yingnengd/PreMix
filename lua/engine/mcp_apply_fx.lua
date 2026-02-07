local r = reaper
local M = {}

local function ensure_proq3(track)
  for i = 0, r.TrackFX_GetCount(track)-1 do
    local _, name = r.TrackFX_GetFXName(track, i, "")
    if name:upper():find("PRO%-Q") then
      return i
    end
  end
  return r.TrackFX_AddByName(track, "Pro-Q 3", false, -1)
end

function M.apply(plan, roles)
  for _, issue in ipairs(plan.issues) do
    for _, resp in ipairs(issue.responsible) do
      local track = roles[resp.role]
      if track then
        local fx = ensure_proq3(track)

        -- 示例：动态 EQ
        if issue.fix.action == "dynamic_eq" then
          -- 这里只做结构，不硬写 index
          -- index mapping 你后面再补
          r.TrackFX_SetParam(track, fx, 4, issue.fix.depth)
        end
      end
    end
  end
end

return M
