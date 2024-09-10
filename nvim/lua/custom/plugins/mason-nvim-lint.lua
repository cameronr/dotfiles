return {
  {
    'rshkarin/mason-nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason-nvim-lint').setup({
        automatic_installation = not vim.g.no_mason_autoinstall,
      })
    end,
  },
}
