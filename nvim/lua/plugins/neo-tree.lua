return {
  'nvim-neo-tree/neo-tree.nvim',
  -- event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  enabled = false,
  branch = 'v3.x',
  keys = {
    { '<leader>e', '<cmd>Neotree toggle reveal<CR>', desc = 'NeoTree', silent = true },
  },
  cmd = 'Neotree',
  opts = {
    use_popups_for_input = false,
    window = {
      mappings = {
        -- Unmap toggle so which-key works
        ['<space>'] = 'none',
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = {
        enabled = true, -- follow the active file in the tree
      },
      use_libuv_file_watcher = true,
    },
  },

  config = function(_, opts)
    require('neo-tree').setup(opts)
    require('lsp-file-operations')
  end,
}
