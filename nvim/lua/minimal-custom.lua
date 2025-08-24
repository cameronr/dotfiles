vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'preview' }
vim.opt.complete = '.,w,b,u,t,i,kspell'
vim.opt.pumheight = 15

-- Tab to move through list, CR to accept, C-Space pop up
vim.keymap.set('i', '<Tab>', function() return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>' end, { expr = true })
vim.keymap.set('i', '<S-Tab>', function() return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>' end, { expr = true })
vim.keymap.set('i', '<CR>', function() return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>' end, { expr = true })
vim.keymap.set('i', '<C-Space>', '<C-x><C-n>', { desc = 'Trigger completion' })

vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChangedP' }, {
  callback = function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local char_before = line:sub(col, col)

    -- Trigger completion after typing a dot or other trigger characters
    if char_before:match('[.:]') then vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-n>', true, false, true), 'n') end
  end,
})
