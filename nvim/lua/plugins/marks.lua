return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'chentoast/marks.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    enabled = false,
    opts = {},
    config = function(_, opts)
      require('marks').setup(opts)

      -- Don't want marks to change number highlight
      vim.api.nvim_set_hl(0, 'MarkSignNumHL', {})
    end,
  },

  {
    'dimtion/guttermarks.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    keys = {
      { 'm;', function() require('guttermarks.actions').delete_mark() end, desc = 'delete mark on current line' },
    },
    opts = {},
  },
}
