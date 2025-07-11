-- Map space to scroll down one page
vim.api.nvim_buf_set_keymap(0, 'n', '<Space>', '<C-f>', { silent = true })

-- Map b to scroll up a page
vim.api.nvim_buf_set_keymap(0, 'n', 'b', '<C-b>', { silent = true })
