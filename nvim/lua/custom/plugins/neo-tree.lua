return {
  'nvim-neo-tree/neo-tree.nvim',
  -- event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'echasnovski/mini.nvim', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  keys = {
    { '<leader>e', '<cmd>Neotree toggle reveal<CR>', desc = 'NeoTree' },
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
}
