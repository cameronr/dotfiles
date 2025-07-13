---@module 'lazy'
---@type LazySpec
return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = { 'BufNewFile', 'BufReadPre' },
  -- event = 'VeryLazy',
  priority = 1000,
  opts = function(_, opts)
    vim.diagnostic.config({ virtual_text = false, float = false })
    return vim.tbl_deep_extend('force', opts or {}, {
      signs = {
        diag = '●',
        vertical = ' │',
        vertical_end = ' └',
        left = '',
        right = '',
        arrow = '   ',
        up_arrow = '  ',
      },
      blend = {
        factor = 0.1,
      },
      options = {
        -- Display the source of the diagnostic (e.g., basedpyright, vsserver, lua_ls etc.)
        -- But only when there are multiple
        show_source = {
          enabled = true,
          if_many = true,
        },
      },
    })
  end,
}
