return {
  'rmagatti/auto-session',
  -- dev = true,
  lazy = false,
  keys = {

    { '<leader>wr', '<cmd>SessionSearch<CR>', desc = 'Session picker' },
    { '<leader>ws', '<cmd>SessionSave<CR>', desc = 'Save session' },
    { '<leader>wD', '<cmd>SessionDelete<CR>', desc = 'Delete session' },
    { '<leader>wa', '<cmd>SessionToggleAutoSave<CR>', desc = 'Toggle autosave session' },
  },

  ---@module "auto-session"
  ---@type AutoSession.Config
  opts = {
    bypass_save_filetypes = { 'alpha' },
    cwd_change_handling = true,
    log_level = 'debug',
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
    },
    suppressed_dirs = { '~/', '~/Downloads', '~/Documents', '~/Desktop', '~/tmp' },
  },
}
