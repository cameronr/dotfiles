---@class PrettyPath.BasePlusHarpoonProvider: PrettyPath.Provider
---@field super PrettyPath.Provider
local M = require('lualine-pretty-path.providers.base'):extend()

function M:render_symbols()
  local harpoonItem, harpoonIndex = require('harpoon'):list():get_by_value(vim.fn.fnamemodify(vim.fn.bufname('%'), ':.'))
  if harpoonItem then
    local harpoonIndexChar = ({ '¹', '²', '³', '⁴', '⁵' })[harpoonIndex]
    -- local harpoonIndexChar = ' '..({ '1', '2', '3', '4', '5' })[harpoonIndex]..'↾'
    return harpoonIndexChar
  end
end

return M
