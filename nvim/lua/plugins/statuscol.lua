return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'luukvbaal/statuscol.nvim',
    event = { 'BufNewFile', 'BufReadPost' },

    -- trying out markit instead for mark toggling
    -- dependencies = {
    --   { 'yaocccc/vim-showmarks' },
    -- },

    opts = function(_, opts)
      local builtin = require('statuscol.builtin')
      return vim.tbl_deep_extend('force', opts or {}, {
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
      })
    end,
  },
}
