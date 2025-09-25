return {
  'A7Lavinraj/fyler.nvim',
  keys = {

    {
      '<Bslash><Bslash>',
      function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'fyler' then return vim.api.nvim_win_close(win, false) end
        end
        require('fyler').open({ kind = 'split_left_most' })
      end,
      desc = 'Fyler',
    },
  },
  ---@module 'fyler'
  ---@type FylerSetupOptions
  opts = {},
}
