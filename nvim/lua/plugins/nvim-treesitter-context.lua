---@module 'lazy'
---@type LazySpec
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    max_lines = 10,
    multiline_threshold = 3,
  },
}
