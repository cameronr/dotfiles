return {
  'NeogitOrg/neogit',
  keys = {
    { '<leader>n', ':Neogit<CR>', desc = 'Neogit' },
  },
  cmd = 'Neogit',
  opts = {
    graph_style = 'unicode',
    commit_editor = {
      staged_diff_split_kind = 'vsplit',
    },
  },
}
