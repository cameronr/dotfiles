-- File for library plugins
return {
  ---@module 'lazy'
  ---@type LazySpec
  { 'nvim-lua/plenary.nvim', lazy = true },

  ---@module 'lazy'
  ---@type LazySpec
  { 'MunifTanjim/nui.nvim', lazy = true },

  ---@module 'lazy'
  ---@type LazySpec
  {
    'zapling/mason-conform.nvim',
    lazy = true,
    opts = {},
  },
}
