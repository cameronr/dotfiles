return {
  'numToStr/Comment.nvim',
  enabled = vim.fn.has('nvim-0.10') ~= 1,
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  config = function()
    -- import comment plugin safely
    local comment = require('Comment')
    local ts_context_commentstring = require('ts_context_commentstring.integrations.comment_nvim')

    ---@diagnostic disable-next-line: missing-fields
    comment.setup({

      -- for commenting tsx, jsx, svelte, html files
      pre_hook = ts_context_commentstring.create_pre_hook(),
    })
  end,
}
