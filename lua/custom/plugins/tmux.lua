return {
  'aserowy/tmux.nvim',
  keys = {
    { '<C-h>', [[<cmd>lua require("tmux").move_left()<cr>]] },
    { '<C-j>', [[<cmd>lua require("tmux").move_bottom()<cr>]] },
    { '<C-k>', [[<cmd>lua require("tmux").move_top()<cr>]] },
    { '<C-l>', [[<cmd>lua require("tmux").move_right()<cr>]] },
    -- { '<C-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
  },
  opts = {
    navigation = {
      cycle_navigation = false,
    },
  },
}
