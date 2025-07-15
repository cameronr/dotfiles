---@module 'lazy'
---@type LazySpec
return {
  'NeogitOrg/neogit',
  keys = {
    { '<leader>n', ':Neogit<CR>', desc = 'Neogit' },
  },
  cmd = 'Neogit',
  opts = {
    -- disable_insert_on_commit = true,
    graph_style = 'unicode',
    commit_editor = {
      staged_diff_split_kind = 'vsplit',
    },
  },
}
