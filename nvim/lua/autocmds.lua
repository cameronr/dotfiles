local user_autocmds_augroup = vim.api.nvim_create_augroup('user_autocmds_augroup', {})

-- Highlight when yanking (copying) text
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = user_autocmds_augroup,
  callback = function() vim.highlight.on_yank() end,
})

-- Both of these from https://www.reddit.com/r/neovim/comments/1abd2cq/what_are_your_favorite_tricks_using_neovim/
-- Jump to last position when reopening a file
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  group = user_autocmds_augroup,
  command = 'silent! normal! g`"zv',
})

-- vim.api.nvim_create_autocmd('BufReadPost', {
--   desc = 'Open file at the last position it was edited earlier',
--   callback = function()
--     local mark = vim.api.nvim_buf_get_mark(0, '"')
--     if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then vim.api.nvim_win_set_cursor(0, mark) end
--   end,
-- })

-- Always open help on the right
-- Open help window in a vertical split to the right.
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = user_autocmds_augroup,
  pattern = { '*.txt' },
  callback = function()
    if vim.o.filetype == 'help' then vim.cmd.wincmd('L') end
  end,
})
