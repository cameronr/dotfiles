return {
  'rachartier/tiny-code-action.nvim',
  -- dev = true,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope.nvim' },
  },
  event = 'LspAttach',
  opts = {
    backend = 'delta',
  },

  config = function(_, opts) require('tiny-code-action').setup(opts) end,
}
