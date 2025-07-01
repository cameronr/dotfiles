return {
  'aserowy/tmux.nvim',
  keys = {
    { '<C-h>', [[<cmd>lua require("tmux").move_left()<cr>]] },
    { '<C-j>', [[<cmd>lua require("tmux").move_bottom()<cr>]] },
    { '<C-k>', [[<cmd>lua require("tmux").move_top()<cr>]] },
    { '<C-l>', [[<cmd>lua require("tmux").move_right()<cr>]] },
    { '<A-h>', [[<cmd>lua require("tmux").move_left()<cr>]] },
    { '<A-j>', [[<cmd>lua require("tmux").move_bottom()<cr>]] },
    { '<A-k>', [[<cmd>lua require("tmux").move_top()<cr>]] },
    { '<A-l>', [[<cmd>lua require("tmux").move_right()<cr>]] },
    -- { '<C-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
  },
  opts = {
    copy_sync = {
      enable = false,
      -- sync_registers_keymap_reg = false,
    },
    navigation = {
      cycle_navigation = false,
    },
    resize = {
      -- enables default keybindings (A-hjkl) for normal mode
      enable_default_keybindings = true,

      -- sets resize steps for x axis
      resize_step_x = 2,

      -- sets resize steps for y axis
      resize_step_y = 2,
    },
  },
}
