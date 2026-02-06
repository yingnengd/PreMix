-- =========================================================
-- MCP Auto Mix Engine
-- Render & Analyze Bridge (v1.0)
--
-- Responsibilities:
-- 1) Render selected MCP buses to temp WAV files
-- 2) Call Python (Essentia) analyzer
-- 3) Produce analysis JSON for Lua engine
--
-- RULES:
-- - No mix decisions here
-- - No plugin manipulation
-- - Fail-safe: analysis errors must NOT break project
-- =========================================================

local r = reaper
local U = require("engine.mcp_utils")

local M = {}

-- ---------------------------------------------------------
-- Configuration
-- ---------------------------------------------------------

-- Python executable (user-adjustable if needed)
M.PYTHON = "python3"

-- Path assumptions (relative to REAPER resource path)
M.ROOT_DIR     = r.GetResourcePath() .. "/Scripts/mcp-auto-mix-engine"
M.ANALYSIS_DIR = M.ROOT_DIR .. "/analysis"
M.PY_SCRIPT    = M.ANALYSIS_DIR .. "/analyze_bus.py"
M.TEMP_DIR     = M.ANALYSIS_DIR .. "/_render"

-- Target buses to render (fixed for v1.0)
M.TARGET_BUSES = {
  VOCAL = "MCP_V_PRESENT_BUS",
  MUSIC = "MCP_MUSIC_BUS"
}

-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------

local function ensure_dir(path)
  -- Create directory if it does not exist
  r.RecursiveCreateDirectory(path, 0)
end

local function find_track_by_name(name)
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

local function render_track_to_wav(track, outfile)
  if not track then return false end

  -- Save current selection
  local sel = {}
  local sel_cnt = r.CountSelectedTracks(0)
  for i = 0, sel_cnt - 1 do
    sel[i+1] = r.GetSelectedTrack(0, i)
  end

  -- Select only target track
  r.Main_OnCommand(40297, 0) -- Unselect all tracks
  r.SetTrackSelected(track, true)

  -- Configure render settings (stems, selected tracks)
  r.GetSetProjectInfo(0, "RENDER_SETTINGS", 3, true) -- stems + selected tracks
  r.GetSetProjectInfo_String(0, "RENDER_FILE", outfile, true)
  r.GetSetProjectInfo_String(0, "RENDER_PATTERN", "", true)

  -- Render
  r.Main_OnCommand(41824, 0) -- Render project, using most recent render settings

  -- Restore selection
  r.Main_OnCommand(40297, 0)
  for _, tr in ipairs(sel) do
    r.SetTrackSelected(tr, true)
  end

  return true
end

local function run_python(input_wav, output_json)
  local cmd = string.format(
    '"%s" "%s" "%s" "%s"',
    M.PYTHON,
    M.PY_SCRIPT,
    input_wav,
    output_json
  )

  -- Execute asynchronously (REAPER shell)
  r.ExecProcess(cmd, 0)
end

-- ---------------------------------------------------------
-- Public API
-- ---------------------------------------------------------

--- Render MCP buses and run Essentia analysis
function M.run()
  ensure_dir(M.TEMP_DIR)

  for key, bus_name in pairs(M.TARGET_BUSES) do
    local track = find_track_by_name(bus_name)
    if not track then
      U.log("[MCP] Bus not found: " .. bus_name)
      goto continue
    end

    local wav_path  = string.format("%s/%s.wav",  M.TEMP_DIR, key:lower())
    local json_path = string.format("%s/%s.json", M.ANALYSIS_DIR, key:lower())

    U.log("[MCP] Rendering bus: " .. bus_name)
    render_track_to_wav(track, wav_path)

    U.log("[MCP] Analyzing: " .. wav_path)
    run_python(wav_path, json_path)

    ::continue::
  end
end

return M
