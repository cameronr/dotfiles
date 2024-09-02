return {
  'gbprod/substitute.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local substitute = require('substitute')

    substitute.setup()

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set('n', '<leader>p', substitute.operator, { desc = 'Paste with motion' })
    keymap.set('n', '<leader>pp', substitute.line, { desc = 'Paste line' })
    keymap.set('n', '<leader>P', substitute.eol, { desc = 'Paste to end of line' })
    keymap.set('x', '<leader>p', substitute.visual, { desc = 'Paste in visual mode' })
  end,
}
