return {
  'smjonas/inc-rename.nvim',
  keys = {
    {
      '<leader>cr',
      function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
      expr = true,
      desc = 'Code: inc-rename',
    },
  },
  cmd = 'IncRename',
  opts = {
    input_buffer_type = 'dressing',
  },
}
