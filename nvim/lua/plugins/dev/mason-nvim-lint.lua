return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'rshkarin/mason-nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      automatic_installation = not vim.g.no_mason_autoinstall,
      ignore_install = {
        'eslint_d', -- handled in lspconfig
      },
    },
  },
}
