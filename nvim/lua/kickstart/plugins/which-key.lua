-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end

return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      delay = 300,
      icons = {
        rules = false,
      },
      spec = {
        { '<leader>a', group = 'Avante' },
        { '<leader>b', group = 'Buffer' },
        { '<leader>c', group = 'Code' },
        { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
        { '<leader>o', group = 'Harpoon' },
        { '<leader>s', group = 'Search' },
        { '<leader>v', group = 'View / UI' },
        { '<leader>w', group = 'Window / Workspace' },
        { '<leader>x', group = 'Trouble' },
        { '<leader><tab>', group = 'Tabs' },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
