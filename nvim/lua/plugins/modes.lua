return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'cameronr/modes.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = function(_, opts)
      opts = opts or {}
      if not vim.g.colors_name or not string.find(vim.g.colors_name, '^tokyonight') then return opts end

      local colors = require('tokyonight.colors').setup()

      return vim.tbl_deep_extend('force', opts or {}, {
        colors = {
          copy = colors.orange,
          delete = colors.red,
          change = colors.yellow,
          format = colors.teal,
          insert = colors.green,
          replace = colors.magenta2,
          visual = '#9745be',

          -- copy = '#f5c359',
          -- delete = '#c75c6a',
          -- change = '#c75c6a', -- Optional param, defaults to delete
          -- format = '#c79585',
          -- insert = '#78ccc5',
          -- replace = '#245361',
          -- select = '#9745be', -- Optional param, defaults to visual
          -- visual = '#9745be',
        },

        set_signcolumn = false,
      })
    end,
  },
}
