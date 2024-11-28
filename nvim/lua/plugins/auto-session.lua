return {
  'rmagatti/auto-session',
  -- dev = true,
  lazy = false,
  keys = {

    { '<leader>wr', '<cmd>SessionSearch<CR>', desc = 'Session picker' },
    { '<leader>ws', '<cmd>SessionSave<CR>', desc = 'Save session' },
    { '<leader>wD', '<cmd>SessionDelete<CR>', desc = 'Delete session' },
  },

  ---@module "auto-session"
  ---@type AutoSession.Config
  ---@diagnostic disable-next-line: assign-type-mismatch
  opts = function()
    Snacks.toggle({
      name = 'session autosave',
      get = function() return require('auto-session.config').auto_save end,
      set = function() vim.cmd('SessionToggleAutoSave') end,
    }):map('<leader>wa')

    return {
      bypass_save_filetypes = { 'alpha' },
      cwd_change_handling = true,
      -- log_level = 'debug',
      lsp_stop_on_restore = true,
      session_lens = {
        load_on_setup = false,
        previewer = true,
        theme_conf = {
          layout_strategy = 'horizontal',
          borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
          sorting_strategy = 'descending',
          layout_config = {
            width = 0.7,
            height = 0.7,
          },
        },
        mappings = {
          delete_session = { 'i', '<M-d>' },
        },
      },
      suppressed_dirs = { '~/', '~/Downloads', '~/Documents', '~/Desktop', '~/tmp' },
    }
  end,
}
