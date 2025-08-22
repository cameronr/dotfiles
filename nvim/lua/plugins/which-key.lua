return {
  ---@module 'lazy'
  ---@type LazySpec
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>sK', function() require('which-key').show({ global = false }) end, desc = 'Buffer Keymaps' },
    },

    ---@module 'which-key'
    ---@type wk.Opts
    opts = {
      preset = 'modern',
      delay = 500,
      icons = {
        rules = false,
      },
      spec = {
        { '<leader>a', group = 'Avante' },
        { '<leader>b', group = 'Buffer' },
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Debug' },
        { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
        { '<leader>o', group = 'Harpoon' },
        { '<leader>t', group = 'Obsidian (todo)' },
        { '<leader>s', group = 'Search', mode = { 'n', 'v' } },
        { '<leader>v', group = 'View / UI' },
        { '<leader>w', group = 'Window / Workspace' },
        { '<leader>x', group = 'Trouble' },
        { '<leader><tab>', group = 'Tabs' },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
