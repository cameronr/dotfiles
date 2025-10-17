return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    ft = 'markdown',
    cmd = 'Obsidian',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },

    keys = {
      { '<leader>so', '<cmd>Obsidian search<CR>', desc = 'Obsidian search' },
      { '<leader>to', '<cmd>Obsidian search<CR>', desc = 'Obsidian search' },
      { '<leader>tn', '<cmd>Obsidian new<CR>', desc = 'Obsidian new' },
    },

    ---@module 'obsidian'
    ---@type obsidian.config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/Library/Mobile Documents/iCloud~md~obsidian/Documents/personal/',
        },
      },
      ---@diagnostic disable-next-line: missing-fields
      completion = {
        nvim_cmp = false,
        blink = true,
      },

      ---@diagnostic disable-next-line: missing-fields
      picker = {
        name = 'snacks.pick',
      },

      ui = {
        ignore_conceal_warn = true,
      },
      checkbox = {
        order = { ' ', 'x' },
      },
      legacy_commands = false,
    },
  },
}
