-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>m', vim.diagnostic.open_float, { desc = 'Show diagnostic error messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- <leader>w
-- Some more convenient keymaps for split management
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Window split vertically' })
vim.keymap.set('n', '<leader>wh', '<C-w>s', { desc = 'Window split horizontally' })
vim.keymap.set('n', '<leader>we', '<C-w>=', { desc = 'Make Window splits equal size' })
vim.keymap.set('n', '<leader>wq', '<cmd>close<CR>', { desc = 'Quit window' })
vim.keymap.set('n', '<leader>q', '<cmd>close<CR>', { desc = 'Quit window' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Close other windows' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

-- Able to use semicolon in normal mode
vim.keymap.set('n', ';', ':', { desc = '; Command mode' })

-- Map jk as alternate escape sequence
vim.keymap.set('i', 'jk', '<Esc>', { desc = 'Exit insert mode with jk' })

-- Sloppy aliases for accidental capital commands
vim.api.nvim_create_user_command('Qa', 'qa', {})
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('X', 'x', {})

-- Remap q: to :q
vim.keymap.set('n', 'q:', ':q')

-- And now kill it with fire (unless brought up by ctrl-f). Credit to:
-- https://www.reddit.com/r/neovim/comments/15bvtr4/what_is_that_command_line_mode_where_i_see_the/
local function escape(keys) return vim.api.nvim_replace_termcodes(keys, true, false, true) end

vim.keymap.set('c', '<C-f>', function()
  vim.g.requested_cmdwin = true
  vim.api.nvim_feedkeys(escape '<C-f>', 'n', false)
end)

vim.api.nvim_create_autocmd('CmdWinEnter', {
  group = vim.api.nvim_create_augroup('CWE', { clear = true }),
  pattern = '*',
  callback = function()
    if vim.g.requested_cmdwin then
      vim.g.requested_cmdwin = nil
    else
      vim.api.nvim_feedkeys(escape ':q<CR>:', 'm', false)
    end
  end,
})

-- Put change into the blackhole register
vim.keymap.set('n', 'c', '"_c')

-- map page up/down to ctrl-u/d
-- now handled in neoscroll
vim.keymap.set({ 'n', 'v', 'x' }, '<pageup>', '<c-u>')
vim.keymap.set({ 'n', 'v', 'x' }, '<pagedown>', '<c-d>')

-- Undo all changes since last save
vim.keymap.set('n', '<S-u>', '<cmd>earlier 1f<CR>', { desc = 'Undo to last saved' })
vim.keymap.set('n', '<C-S-R>', '<cmd>later 1f<CR>', { desc = 'Redo to last saved' })

-- <leader>t
-- -- Next/prev tabs
vim.keymap.set('n', '[t', '<cmd>:tabprevious<CR>', { desc = 'Previous tab' })
vim.keymap.set('n', ']t', '<cmd>:tabnext<CR>', { desc = 'Next tab' })
vim.keymap.set('n', '<leader>tq', '<cmd>:tabclose<CR>', { desc = 'Close tab' })

vim.keymap.set('n', '<leader>tl', '<cmd>Lazy<CR>', { desc = 'Open Lazy' })
vim.keymap.set('n', '<leader>tm', '<cmd>Mason<CR>', { desc = 'Open Mason' })

-- Next/prev buffer
vim.keymap.set('n', '[b', '<cmd>:bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', '<cmd>:bnext<CR>', { desc = 'Next buffer' })

-- <leader>b
vim.keymap.set('n', '<leader>bq', '<cmd>:bdelete<CR>', { desc = 'Close buffer' })

-- Shortcute for surrounding a word (inner) with a '
vim.keymap.set('n', 'wq', "waiw'", { desc = "Wrap word with '", remap = true })
vim.keymap.set('n', 'wb', 'waaw}', { desc = 'Wrap word with {}', remap = true })

-- Debugging key
vim.keymap.set('n', '<Bslash>d', function() end)

-- vim: ts=2 sts=2 sw=2 et
