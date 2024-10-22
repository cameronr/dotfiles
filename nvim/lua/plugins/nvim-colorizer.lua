return {
  'NvChad/nvim-colorizer.lua',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    user_default_options = {
      virtualtext = '⬤ ',
      mode = 'virtualtext',
      names = false,
    },
  },
}
