return {
  'A7Lavinraj/fyler.nvim',
  keys = {
    {
      '<Bslash><Bslash>',
      function() require('fyler').toggle({ kind = 'split_left_most' }) end,
      desc = 'Fyler',
    },
  },
  ---@module 'fyler'
  ---@type FylerSetupOptions
  opts = {
    mappings = {
      ['-'] = 'GotoParent',
    },
  },
}
