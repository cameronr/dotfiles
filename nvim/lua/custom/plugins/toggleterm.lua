return {
  'akinsho/toggleterm.nvim',
  cmds = {
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
