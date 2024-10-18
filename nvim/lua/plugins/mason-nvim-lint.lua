return {
  {
    'rshkarin/mason-nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      automatic_installation = not vim.g.no_mason_autoinstall,
    },
  },
}
