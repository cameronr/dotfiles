---@module 'lazy'
---@type LazySpec
return {
  'akinsho/bufferline.nvim',
  version = '*',
  event = { 'TabNew' },
  opts = {
    options = {
      mode = 'tabs',
      always_show_bufferline = false,
    },
  },
}
