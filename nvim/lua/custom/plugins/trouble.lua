return {
  'folke/trouble.nvim',
  dependencies = { 'folke/todo-comments.nvim' },
  opts = {}, -- for default options, refer to the configuration section for custom setup.
  cmd = 'Trouble',
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<leader>xs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Symbols (Trouble)',
    },
    {
      '<leader>xL',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'LSP Definitions / references / ... (Trouble)',
    },
    {
      '<leader>xl',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Location List (Trouble)',
    },
    {
      '<leader>xq',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Quickfix List (Trouble)',
    },
    {
      '<leader>xt',
      '<cmd>Trouble todo toggle<cr>',
      desc = 'Todos (Trouble)',
    },
    -- Borrowed from LazyVim
    {
      '[q',
      function()
        if require('trouble').is_open() then
          require('trouble').prev({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end,
      desc = 'Previous Trouble/Quickfix Item',
    },
    {
      ']q',
      function()
        if require('trouble').is_open() then
          require('trouble').next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then vim.notify(err, vim.log.levels.ERROR) end
        end
      end,
      desc = 'Next Trouble/Quickfix Item',
    },
    {
      '<leader>xQ',
      '<cmd>Trouble close<cr>',
      desc = 'Close Trouble',
    },
  },
}
