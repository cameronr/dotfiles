-- Borrowed shamelessley from Lazyvim and then modified
---@class custom.util.lualine
local M = {}

-- currently unused
function M.harpoon_status()
  -- only run this if harpoon has been loaded
  local nvim_harpoon_config = require('lazy.core.config').plugins['harpoon']
  if not nvim_harpoon_config or not nvim_harpoon_config._.loaded then return '' end

  local filename = vim.fn.bufname('%')
  local harpoonItem, harpoonIndex = require('harpoon'):list():get_by_value(filename)
  if harpoonItem then return harpoonIndex .. '↾' end
  -- ↼ (LEFTWARDS HARPOON WITH BARB UPWARDS)
  -- ↽ (LEFTWARDS HARPOON WITH BARB DOWNWARDS)
  -- ↾ (UPWARDS HARPOON WITH BARB RIGHTWARDS)
  -- ↿ (UPWARDS HARPOON WITH BARB LEFTWARDS)
  -- ⇀ (RIGHTWARDS HARPOON WITH BARB UPWARDS)
  -- ⇁ (RIGHTWARDS HARPOON WITH BARB DOWNWARDS)
  -- ⇂ (DOWNWARDS HARPOON WITH BARB RIGHTWARDS)
  -- ⇃ (DOWNWARDS HARPOON WITH BARB LEFTWARDS)
  return ''
end

function M.cmp_source(name, icon)
  local started = false
  local function status()
    -- only run this if cmp has been loaded
    local nvim_cmp_config = require('lazy.core.config').plugins['nvim-cmp']
    if not nvim_cmp_config or not nvim_cmp_config._.loaded then return nil end

    for _, s in ipairs(require('cmp').core.sources) do
      if s.name == name then
        if s.source:is_available() then
          started = true
        else
          return started and 'error' or nil
        end
        if s.status == s.SourceStatus.FETCHING then return 'pending' end
        return 'ok'
      end
    end
  end

  local highlighs = {
    ok = 'Special',
    error = 'DiagnosticError',
    pending = 'DiagnosticWarn',
  }

  local colors = {}

  -- We don't use the highlights so it'll match the lualine bg
  for key, hl_name in pairs(highlighs) do
    local hl = vim.api.nvim_get_hl(0, { name = hl_name })
    colors[key] = string.format('#%06x', hl.fg)
  end

  return {
    function()
      return icon -- or LazyVim.config.icons.kinds[name:sub(1, 1):upper() .. name:sub(2)]
    end,

    cond = function() return status() ~= nil end,
    color = function() return { fg = colors[status()] } or { fg = colors.ok } end,
    separator = '',
  }
end

return M
