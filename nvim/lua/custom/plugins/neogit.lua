return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- required
    'sindrets/diffview.nvim', -- optional - Diff integration

    -- Only one of these is needed, not both.
    'nvim-telescope/telescope.nvim', -- optional
  },
  keys = {
    { '<leader>n', ':Neogit<CR>', desc = '[N]eoGit' },
  },
  config = function()
    require('neogit').setup {
      ---@diagnostic disable-next-line: missing-fields
      commit_editor = {
        staged_diff_split_kind = 'vsplit',
      },
    }
  end,
}
