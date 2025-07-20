return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'chentoast/marks.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
    config = function(_, opts)
      require('marks').setup(opts)

      -- Don't want marks to change number highlight
      vim.api.nvim_set_hl(0, 'MarkSignNumHL', {})
    end,
  },
}
