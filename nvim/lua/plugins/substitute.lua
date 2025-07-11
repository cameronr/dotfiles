-- show marks in sign column

-- don't show line number in virtual lines when wrapping
---@module 'lazy'
---@type LazySpec
return {
  'gbprod/substitute.nvim',
  keys = {
    { '<leader>p', function() require('substitute').operator() end, desc = 'Paste with motion' },
    { '<leader>pp', function() require('substitute').line() end, desc = 'Paste line' },
    { '<leader>P', function() require('substitute').eol() end, desc = 'Paste to end of line' },
    { '<leader>p', function() require('substitute').visual() end, mode = 'x', desc = 'Paste in visual mode' },
  },
  opts = {},
}
