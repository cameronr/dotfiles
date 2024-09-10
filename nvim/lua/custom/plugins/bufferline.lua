return {
  'akinsho/bufferline.nvim',
  version = '*',
  event = { 'BufNewFile', 'BufReadPre' },
  dependencies = 'echasnovski/mini.nvim',
  opts = {
    options = {
      mode = 'tabs',
      always_show_bufferline = false,
    },
  },
}
