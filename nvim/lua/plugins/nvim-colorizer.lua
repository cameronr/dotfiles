return {
  'cameronr/nvim-colorizer.lua',
  -- dev = true,
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    user_default_options = {
      virtualtext = '⬤ ',
      mode = 'virtualtext',
      names = false,
    },
    filetypes = {
      '*',
      '!cmp_menu',
      '!fidget',
      '!notify',
      '!TelescopeResults',
      '!TelescopePrompt',
    },
  },
}
