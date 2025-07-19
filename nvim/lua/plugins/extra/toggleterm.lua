---@module 'lazy'
---@type LazySpec
return {
  'akinsho/toggleterm.nvim',
  cmd = {
    'ToggleTerm',
  },
  keys = {
    { '<c-\\>', 'ToggleTerm' },
  },
  opts = {
    open_mapping = [[<c-\>]],
    direction = 'float',
  },
}
