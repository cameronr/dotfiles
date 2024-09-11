return {
  'sindrets/diffview.nvim',
  -- lazy = true,
  keys = {
    { '<leader>hd', '<cmd>DiffviewOpen<CR>', desc = 'git diff against index' },
  },
  cmd = 'DiffviewOpen',
  opts = {
    enhanced_diff_hl = true,
    hooks = {
      diff_buf_win_enter = function(bufnr, winid, ctx)
        -- Turn off cursor line for diffview windows because of BG conflict
        -- setting gross underline:
        -- https://github.com/neovim/neovim/issues/9800
        vim.wo[winid].culopt = 'number'
      end,
    },
  },
}
