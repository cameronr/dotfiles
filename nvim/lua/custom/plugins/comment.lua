return {
  'numToStr/Comment.nvim',
  -- event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  keys = {
    { '<Bslash>x', mode = { 'n', 'v', 'x' }, desc = 'Toggle comment' },
  },
  config = function()
    -- import comment plugin safely
    local comment = require('Comment')
    local ts_context_commentstring = require('ts_context_commentstring.integrations.comment_nvim')

    ---@diagnostic disable-next-line: missing-fields
    comment.setup({
      ---@diagnostic disable-next-line: missing-fields
      toggler = { line = '<Bslash>x' },
      ---@diagnostic disable-next-line: missing-fields
      opleader = { line = '<Bslash>x' },

      -- for commenting tsx, jsx, svelte, html files
      pre_hook = ts_context_commentstring.create_pre_hook(),
    })
  end,
}
