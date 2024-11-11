return {
  'tzachar/highlight-undo.nvim',
  keys = {
    { 'u' },
    { '<C-r>' },
    -- TODO: add keymaps for S-u, M-u, M-r
  },
  opts = {
    Paste = {
      disabled = true,
    },
  },
}
