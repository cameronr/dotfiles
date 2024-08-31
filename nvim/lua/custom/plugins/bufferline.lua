return {
  'akinsho/bufferline.nvim',
  version = '*',
  event = { 'BufNew' },
  dependencies = 'echasnovski/mini.nvim',
  opts = {
    options = {
      mode = 'tabs',
      always_show_bufferline = false,
    },
  },
}
