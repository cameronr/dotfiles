return {
  'rachartier/tiny-code-action.nvim',
  enabled = false,
  -- dev = true,
  event = 'LspAttach',
  opts = {
    backend = 'delta',
  },

  config = function(_, opts) require('tiny-code-action').setup(opts) end,
}
