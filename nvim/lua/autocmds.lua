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

-- -- Disable relative line numbers when leaving a window
-- vim.api.nvim_create_autocmd('WinLeave', {
--   group = user_autocmds_augroup,
--   callback = function(event)
--     -- vim.notify('winleave: ' .. vim.inspect(event))
--     vim.w.had_relativenumber = vim.wo.relativenumber
--     vim.wo.relativenumber = false
--   end,
-- })
--
-- -- Restore relative line numbers when entering a window
-- vim.api.nvim_create_autocmd('WinEnter', {
--   group = user_autocmds_augroup,
--   callback = function(event)
--     -- vim.notify('winent: ' .. vim.inspect(event))
--     if vim.w.had_relativenumber ~= nil then vim.wo.relativenumber = vim.w.had_relativenumber end
--   end,
-- })

local function markdown_keymaps()
  vim.keymap.set('i', '<CR>', function()
    local line = vim.api.nvim_get_current_line()
    local checkbox_pat = '^%s*%- %[[ xX]?%]'
    local bullet_pat = '^%s*%-'

    if line:match(checkbox_pat) then
      return '<CR>- [ ] '
    elseif line:match(bullet_pat) then
      return '<CR>- '
    else
      return '<CR>'
    end
  end, { buffer = true, expr = true })

  local function move_checked_item()
    local buf = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line_num = cursor_pos[1] - 1

    -- Get the current line content
    local current_line = vim.api.nvim_buf_get_lines(buf, current_line_num, current_line_num + 1, false)[1]

    -- Check if current line is checked
    if not current_line:match('^%s*[%-%*%+]%s*%[%s*[xX]%s*%]') then return end

    -- Find first empty line or checked line below current position
    local total_lines = vim.api.nvim_buf_line_count(buf)
    local target_line = nil

    for line_num = current_line_num + 1, total_lines do
      local line = vim.api.nvim_buf_get_lines(buf, line_num, line_num + 1, false)[1]
      if not line or line == '' or line:match('^%s*[%-%*%+]%s*%[%s*[xX]%s*%]') then
        target_line = line_num
        break
      end
    end

    -- If no target found, move to end of buffer
    if not target_line then target_line = total_lines + 1 end

    -- Cut current line and insert BEFORE target (to be at top of checked items)
    vim.api.nvim_buf_set_lines(buf, current_line_num, current_line_num + 1, false, {})
    vim.api.nvim_buf_set_lines(buf, target_line - 1, target_line - 1, false, { current_line })

    -- adjust cursor so it doesn't move down if checking and then rechecking in the completed section
    if target_line == cursor_pos[1] then vim.api.nvim_win_set_cursor(0, { target_line, cursor_pos[2] }) end
  end

  -- Create a command to call the function
  vim.api.nvim_create_user_command('MoveChecked', move_checked_item, {
    desc = 'Sort checked markdown items to the bottom of the current paragraph',
  })

  local function smarter_action()
    local cmd = require('obsidian.api').smart_action():match('<cmd>(.-)<cr>')
    if not cmd then return end
    vim.cmd(cmd)
    if cmd:find('toggle_checkbox', 1, true) then move_checked_item() end
  end

  vim.keymap.set('n', '<CR>', function() smarter_action() end, { buffer = true })
  vim.keymap.set('n', '<C-a>', function() smarter_action() end, { buffer = true })
  vim.keymap.set('v', '<C-a>', function() smarter_action() end, { buffer = true })
end

vim.api.nvim_create_autocmd('User', {
  group = user_autocmds_augroup,
  pattern = 'ObsidianNoteEnter',
  callback = markdown_keymaps,
})

vim.api.nvim_create_autocmd('filetype', {
  group = user_autocmds_augroup,
  pattern = 'markdown',
  callback = markdown_keymaps,
})
