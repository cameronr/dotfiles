return {
  'NeogitOrg/neogit',
  keys = {
    { '<leader>n', ':Neogit<CR>', desc = 'NeoGit' },
  },
  cmd = 'NeoGit',
  opts = {
    graph_style = 'unicode',
    commit_editor = {
      staged_diff_split_kind = 'vsplit',
    },
  },
}
