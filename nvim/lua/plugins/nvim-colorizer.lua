---@module 'lazy'
---@type LazySpec
return {
  'catgoose/nvim-colorizer.lua',
  -- dev = true,
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    user_default_options = {
      RGB = true,
      RRGGBB = true,
      names = false,
      RRGGBBAA = true,
      AARRGGBB = true,
      rgb_fn = true,
      hsl_fn = true,
      css = true,
      css_fn = true,
      -- mode = 'background',
      mode = 'virtualtext',
      tailwind = 'lsp',
      sass = {
        enable = false,
        parsers = { 'css' },
      },
      virtualtext = '⬤ ',
    },
    buftypes = { '!prompt', '!popup' },

    filetypes = {
      '*',
      '!cmp_menu',
      '!fidget',
      '!notify',
      '!TelescopeResults',
      '!TelescopePrompt',
      '!lazy',
    },
  },
}
