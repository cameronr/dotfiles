return {
  'sindrets/diffview.nvim',
  -- lazy = true,
  keys = {
    { '<leader>hd', '<cmd>DiffviewOpen<CR>', desc = 'git [d]iff against index' },
  },
  cmd = 'DiffviewOpen',
  opts = {
    enhanced_diff_hl = true,
  },
}
