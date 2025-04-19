return {
  -- show marks in sign column

  -- don't show line number in virtual lines when wrapping
  {
    'luukvbaal/statuscol.nvim',
    event = { 'BufNewFile', 'BufReadPost' },

    dependencies = {
      { 'yaocccc/vim-showmarks' },
    },

    opts = {
      relculright = true,
    },
  },
}
