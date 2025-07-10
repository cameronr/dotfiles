-- File for library plugins
return {
  { 'nvim-lua/plenary.nvim', lazy = true },
  { 'MunifTanjim/nui.nvim', lazy = true },
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
