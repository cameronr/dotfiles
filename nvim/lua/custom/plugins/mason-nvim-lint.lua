return {
  {
    'rshkarin/mason-nvim-lint',
    event = 'VeryLazy',
    config = function()
      require('mason-nvim-lint').setup {
        automatic_installation = true,
      }
    end,
  },
}
