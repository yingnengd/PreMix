local r = reaper
local M = {}

function M.scan_project()
  local roles = {}

  for i = 0, r.CountTracks(0)-1 do
    local tr = r.GetTrack(0, i)
    local _, name = r.GetTrackName(tr)

    if name:find("VOCAL") then
      roles["VOCAL"] = tr
    elseif name:find("MUSIC") then
      roles["MUSIC"] = tr
    end
  end

  return roles
end

return M
