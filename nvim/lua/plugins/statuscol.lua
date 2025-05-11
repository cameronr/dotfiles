return {
  -- show marks in sign column

  -- don't show line number in virtual lines when wrapping
  {
    'luukvbaal/statuscol.nvim',
    event = { 'BufNewFile', 'BufReadPost' },

    dependencies = {
      { 'yaocccc/vim-showmarks' },
    },

    opts = function()
      local builtin = require('statuscol.builtin')
      return {
        relculright = true,
        segments = {
          {
            sign = {
              text = { '.*' }, -- to capture diagnostics and gitsigns
              name = { '.*' }, -- to capture todo-comments signs, marks
              maxwidth = 1,
              colwidth = 1,
            },
            click = 'v:lua.ScSa',
          },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            -- click = 'v:lua.ScLa', -- NOTE: uncomment for DAP breakpoint toggling
          },
        },
      }
    end,
  },
}
