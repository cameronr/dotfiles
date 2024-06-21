return {
  {
    'rshkarin/mason-nvim-lint',
    config = function()
      require('mason-nvim-lint').setup {
        automatic_installation = true,
      }
    end,
  },
}
