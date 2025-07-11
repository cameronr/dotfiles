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
    opts = {
      ensure_installed = {},
      -- need a specific version of eslint_d so don't install it here
      ignore_install = { 'eslint_d' },
    },
  },
}
