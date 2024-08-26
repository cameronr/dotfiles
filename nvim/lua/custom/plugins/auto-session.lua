return {
  'rmagatti/auto-session',
  -- dev = true,
  lazy = false,
  keys = {

    { '<leader>wr', '<cmd>SessionSearch<CR>', desc = 'Session picker' },
    { '<leader>ws', '<cmd>SessionSave<CR>', desc = 'Save session' },
    { '<leader>wa', '<cmd>SessionToggleAutoSave<CR>', desc = 'Toggle autosave session' },
  },

  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    bypass_session_save_file_types = { 'alpha' },
    log_level = 'debug',
    auto_session_suppress_dirs = { '~/', '~/Downloads', '~/Documents', '~/Desktop', '~/tmp' },
    session_lens = {
      load_on_setup = false,
      previewer = true,
      theme_conf = {
        layout_config = {
          height = 0.4,
        },
      },
    },
    cwd_change_handling = {
      restore_upcoming_session = true,
    },
  },
}
