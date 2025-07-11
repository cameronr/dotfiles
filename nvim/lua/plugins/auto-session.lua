---@module 'lazy'
---@type LazySpec
return {
  'rmagatti/auto-session',
  -- dev = true,
  lazy = false,
  keys = {

    { '<leader>wr', '<cmd>SessionSearch<CR>', desc = 'Session picker' },
    { '<leader>ws', '<cmd>SessionSave<CR>', desc = 'Save session' },
    { '<leader>wD', '<cmd>SessionDelete<CR>', desc = 'Delete session' },
  },

  opts = function(_, opts)
    if Snacks then
      Snacks.toggle({
        name = 'session autosave',
        get = function() return require('auto-session.config').auto_save end,
        set = function() vim.cmd('SessionToggleAutoSave') end,
      }):map('<leader>wa')
    end

    ---@module "auto-session"
    ---@type AutoSession.Config
    return vim.tbl_deep_extend('force', opts or {}, {
      bypass_save_filetypes = { 'alpha', 'snacks_dashboard' },
      cwd_change_handling = true,
      -- log_level = 'debug',
      lsp_stop_on_restore = true,
      pre_restore_cmds = {
        function() require('harpoon'):sync() end,
      },
      post_restore_cmds = {
        function()
          local harpoon = require('harpoon')
          harpoon.data = require('harpoon.data').Data:new(harpoon.config)
        end,
      },
      session_lens = {
        load_on_setup = false,
        mappings = {
          delete_session = { 'i', '<a-d>' },
        },
      },
      suppressed_dirs = { '~/', '~/Downloads', '~/Documents', '~/Desktop', '~/tmp' },
    })
  end,
}
