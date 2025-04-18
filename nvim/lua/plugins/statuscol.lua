return {
  -- show marks in sign column
  { 'yaocccc/vim-showmarks' },

  -- don't show line number in virtual lines when wrapping
  {
    'luukvbaal/statuscol.nvim',
    event = { 'BufNewFile', 'BufReadPost' },

    opts = {
      relculright = true,
    },
  },
}
