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
    if vim.o.filetype ~= 'help' then return end

    local function has_diffview_in_current_tab()
      return vim.tbl_contains(
        vim.tbl_map(function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype end, vim.api.nvim_tabpage_list_wins(0)),
        'DiffviewFiles'
      )
    end

    if has_diffview_in_current_tab() then return end

    vim.cmd.wincmd('L')
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = user_autocmds_augroup,
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Disable relative line numbers when leaving a window
vim.api.nvim_create_autocmd('WinLeave', {
  group = user_autocmds_augroup,
  callback = function()
    vim.w.had_relativenumber = vim.wo.relativenumber
    vim.wo.relativenumber = false
  end,
})

-- Restore relative line numbers when entering a window
vim.api.nvim_create_autocmd('WinEnter', {
  group = user_autocmds_augroup,
  callback = function()
    if vim.w.had_relativenumber ~= nil then vim.wo.relativenumber = vim.w.had_relativenumber end
  end,
})
