return {
  'nvim-neo-tree/neo-tree.nvim',
  -- event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  keys = {
    { '<leader>e', '<cmd>Neotree toggle reveal<CR>', { desc = 'NeoTree toggle' } },
  },
  opts = {
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
    },
  },
}
