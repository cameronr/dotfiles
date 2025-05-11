return {
  {
    '2kabhishek/markit.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      mappings = {
        set = 'M',
        toggle_mark = 'm',
      },
    },
  },
}
