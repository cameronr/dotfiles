---@module 'lazy'
---@type LazySpec
return {
  'Wansmer/treesj',
  keys = {
    { 'gS', '<cmd>TSJSplit<cr>', desc = 'Split/Join' },
    { 'gJ', '<cmd>TSJJoin<cr>', desc = 'Split/Join' },
  },
  opts = {
    use_default_keymaps = false,
    max_join_length = 2000,
  },
}
