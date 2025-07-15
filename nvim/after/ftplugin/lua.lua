-- Testing
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>ct', '<cmd>PlenaryBustedFile %<CR>', { desc = 'Test file' })
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>cT', '<cmd>PlenaryBustedFile %<CR>', { desc = 'Test directory' })
