-- =========================================================
-- MCP Fix Rules (Plugin Agnostic)
-- =========================================================

local M = {}

-- score ∈ 0..1
-- 返回的是「语义动作」，不是插件参数

M.VOCAL = {
  PAD = function(score)
    return {
      presence_cut = score * 3.0,
      dynamic      = true
    }
  end,

  DOUBLE = function(score)
    return {
      presence_cut = score * 1.8,
      width_limit  = score * 0.5
    }
  end,

  HARM = function(score)
    return {
      presence_cut = score * 1.2
    }
  end
}

M.MUSIC = {
  MID = function(score)
    return {
      sidechain_duck = score * 2.5
    }
  end
}

return M
