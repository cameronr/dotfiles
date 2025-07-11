---@module 'lazy'
---@type LazySpec
return {
  'rachartier/tiny-inline-diagnostic.nvim',
  enabled = vim.fn.has('nvim-0.10') == 1,
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
      },
      blend = {
        factor = 0.1,
      },
    })
  end,
}
