-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><esc>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Diagnostic popup' })

-- Quickfix
vim.keymap.set('n', '[q', '<cmd>cprev<cr>', { desc = 'Previous quickfix' })
vim.keymap.set('n', ']q', '<cmd>cnext<cr>', { desc = 'Next quickfix' })

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
vim.keymap.set('n', '<leader>w<Bslash>', '<C-w>v', { desc = 'Window split vertically' })
vim.keymap.set('n', '<leader>w|', '<C-w>v', { desc = 'Window split vertically' })
vim.keymap.set('n', '<leader>wh', '<C-w>s', { desc = 'Window split horizontally' })
vim.keymap.set('n', '<leader>w-', '<C-w>s', { desc = 'Window split horizontally' })
vim.keymap.set('n', '<leader>we', '<C-w>=', { desc = 'Make Window splits equal size' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Make Window splits equal size' })
vim.keymap.set('n', '<leader>wq', '<cmd>close<CR>', { desc = 'Quit window' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Close other windows' })
vim.keymap.set('n', '<leader>wH', '<C-w>H', { desc = 'Move window left' })
vim.keymap.set('n', '<leader>wL', '<C-w>L', { desc = 'Move window right' })
vim.keymap.set('n', '<leader>wJ', '<C-w>J', { desc = 'Move window down' })
vim.keymap.set('n', '<leader>wK', '<C-w>K', { desc = 'Move window up' })

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

-- blackhole single x
vim.keymap.set('n', 'x', '"_x')

-- Put change into the blackhole register
vim.keymap.set('n', 'c', '"_c')

-- Able to use semicolon in normal mode
vim.keymap.set('n', ';', ':', { desc = '; Command mode' })

-- Map jk as alternate escape sequence
vim.keymap.set({ 'i', 'c' }, 'jk', '<Esc>', { desc = 'Exit insert / cmd mode with jk' })

-- Sloppy aliases for accidental capital commands
-- in 0.10, could use vim.keymap.set("ca", ...)
vim.api.nvim_create_user_command('Qa', 'qa', {})
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('X', 'x', {})

-- Remap q: to :q
vim.keymap.set('n', 'q:', ':q')

vim.keymap.set('n', 'q', '<nop>', { noremap = true })
vim.keymap.set('n', 'Q', 'q', { noremap = true, desc = 'Record macro' })
vim.keymap.set('n', '<M-q>', 'Q', { noremap = true, desc = 'Replay last register' })

-- And now kill it with fire (unless brought up by ctrl-f). Credit to:
-- https://www.reddit.com/r/neovim/comments/15bvtr4/what_is_that_command_line_mode_where_i_see_the/
local function escape(keys) return vim.api.nvim_replace_termcodes(keys, true, false, true) end

vim.keymap.set('c', '<C-f>', function()
  vim.g.requested_cmdwin = true
  vim.api.nvim_feedkeys(escape('<C-f>'), 'n', false)
end)

vim.api.nvim_create_autocmd('CmdWinEnter', {
  group = vim.api.nvim_create_augroup('CWE', { clear = true }),
  pattern = '*',
  callback = function()
    if vim.g.requested_cmdwin then
      vim.g.requested_cmdwin = nil
    else
      vim.api.nvim_feedkeys(escape(':q<CR>:'), 'm', false)
    end
  end,
})

-- Borrowed from LazyVim

-- better up/down
vim.keymap.set({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
vim.keymap.set({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set('n', '<M-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<M-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<M-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<M-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Move Lines
vim.keymap.set('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Move Down' })
vim.keymap.set('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Move Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<cr>gv=gv", { desc = 'Move Down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<cr>gv=gv", { desc = 'Move Up' })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- -- Next/prev tabs
vim.keymap.set('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
vim.keymap.set('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
vim.keymap.set('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
vim.keymap.set('n', '<leader><tab>n', '<cmd>tabnew<cr>', { desc = 'New Tab' })
vim.keymap.set('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
vim.keymap.set('n', '<leader><tab><tab>', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
vim.keymap.set('n', '<leader><tab><S-tab>', '<cmd>tabprev<cr>', { desc = 'Previous Tab' })
vim.keymap.set('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
vim.keymap.set('n', '<leader><tab>q', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
vim.keymap.set('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- better indenting
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- save file
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go({ severity = severity }) end
end
vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
vim.keymap.set('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
vim.keymap.set('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

-- End LazyVim

-- Old comment keymap
vim.keymap.set('n', '<bslash>x', 'gcc', { desc = 'Comment toggle', remap = true })
vim.keymap.set({ 'v', 'x' }, '<bslash>x', 'gc', { desc = 'Comment toggle', remap = true })

-- map page up/down to ctrl-u/d
vim.keymap.set({ 'n', 'v', 'x' }, '<pageup>', '<c-u>')
vim.keymap.set({ 'n', 'v', 'x' }, '<pagedown>', '<c-d>')

-- Undo all changes since last save
vim.keymap.set('n', '<S-u>', '<cmd>earlier 1f<CR>', { desc = 'Undo to last saved' })
vim.keymap.set('n', '<M-u>', '<cmd>earlier 1f<CR>', { desc = 'Undo to last saved' })
vim.keymap.set('n', '<M-r>', '<cmd>later 1f<CR>', { desc = 'Redo to last saved' })

-- Tools
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<CR>', { desc = 'Lazy' })
vim.keymap.set('n', '<leader>cm', '<cmd>Mason<CR>', { desc = 'Mason' })

-- Next/prev buffer
vim.keymap.set('n', '[b', '<cmd>:bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', ']b', '<cmd>:bnext<CR>', { desc = 'Next buffer' })

-- <leader>b
vim.keymap.set('n', '<leader>bq', '<cmd>bd<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bQ', '<cmd>bd!<CR>', { desc = 'Force close buffer' })
vim.keymap.set('n', '<leader>bd', '<cmd>bd<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>bD', '<cmd>bd!<CR>', { desc = 'Force close buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>enew<CR>', { desc = 'New buffer' })

-- Shortcut for surrounding a word (inner) with a '
vim.keymap.set('n', 'S', '<nop>') -- Don't keep S mapping
vim.keymap.set('n', 'Sq', "Siw'", { desc = "Wrap word with '", remap = true })
vim.keymap.set('n', 'Sp', 'SiW(', { desc = 'Wrap word with ()', remap = true })
vim.keymap.set('n', 'Sb', 'Saw}', { desc = 'Wrap word with {}', remap = true })

-- Swap to alternate buffer, less work that ctrl-6
vim.keymap.set('n', '<leader>a', '<C-6>', { desc = 'Alt buffer' })
vim.keymap.set('n', '<leader>,', '<C-6>', { desc = 'Alt buffer' })

-- quick replace of current word
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>r', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Replace current word' })

-- select last pasted lines
vim.keymap.set('n', 'gp', "'[V']", { desc = 'Select pasted lines' })

-- view options
vim.keymap.set('n', '<leader>vl', function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.opt.background:get() == 'dark' then
    vim.opt.background = 'light'
  else
    vim.opt.background = 'dark'
  end
end, { desc = 'Toggle light/dark' })

vim.keymap.set('n', '<leader>vz', function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.opt.foldcolumn:get() == '0' then
    vim.opt.foldcolumn = '1'
  else
    vim.opt.foldcolumn = '0'
  end
end, { desc = 'Toggle foldcolumn' })

vim.keymap.set('n', '<leader>vP', function() vim.g.minipairs_disable = not vim.g.minipairs_disable and true or false end, { desc = 'Toggle mini.pairs' })

vim.keymap.set('n', '<leader>vc', function()
  ---@diagnostic disable-next-line: undefined-field
  vim.opt.cursorline = not vim.opt.cursorline:get()
end, { desc = 'Toggle cursorline' })

vim.keymap.set('n', '<leader>vt', '<cmd>TSToggle highlight<CR>', { desc = 'Toggle Treesitter highlight' })
vim.keymap.set('n', '<leader>vL', function() vim.b.trouble_lualine = not (vim.b.trouble_lualine ~= false) end, { desc = 'Toggle Trouble Lualine' })
vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, { desc = 'Toggle diagnosics' })
vim.keymap.set('n', '<leader>vh', '<cmd>nohl<CR>', { desc = 'Clear highlights' })
vim.keymap.set('n', '<leader>vw', function() vim.opt_local.wrap = not vim.opt_local.wrap:get() end, { desc = 'Toggle line wrap' })
vim.keymap.set('n', '<leader>vr', vim.cmd.checktime, { desc = 'Check for file changes' })

vim.keymap.set('n', '<leader>t', '<cmd>InspectTree<cr>', { desc = 'Inspect TS Tree' })

-- Debugging key
vim.keymap.set('n', '<Bslash>d', function()
  -- local harpoon = require('harpoon')
  --
  -- vim.notify(vim.inspect(harpoon:list().items))

  -- vim.g.statusline_winid = vim.api.nvim_get_current_win()
  -- local current_win = vim.api.nvim_get_current_win()
  --
  -- local start_time = vim.uv.hrtime()
  --
  -- for i = 1, 100000 do
  --   require('statuscol').StatusCol({ win = current_win })
  -- end
  -- -- code to be profiled
  --
  -- local end_time = vim.uv.hrtime()
  -- vim.notify('Require time: ' .. end_time - start_time)
  --
  -- vim.g.statusline_winid = vim.api.nvim_get_current_win()
  --
  -- start_time = vim.uv.hrtime()
  --
  -- for i = 1, 100000 do
  --   StatusCol({ win = current_win })
  -- end
  -- -- code to be profiled
  --
  -- end_time = vim.uv.hrtime()
  --
  -- vim.notify('Function time: ' .. end_time - start_time)

  -- local start = vim.loop.hrtime()
  -- your_function()
  -- local end = vim.loop.hrtime()
  -- print(string.format("Elapsed time: %.6f", (end - start) / 1e6))  -- Convert nanoseconds to milliseconds
  --
  -- local bufs = vim.api.nvim_list_bufs()
  -- for _, buf in ipairs(bufs) do
  --   local filename = vim.api.nvim_buf_get_name(buf)
  --   local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })
  --   local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
  --   vim.notify(buf .. ': file_name: ' .. filename .. ' buftype: ' .. buftype .. ' filetype: ' .. filetype)
  -- end

  -- local filename = vim.fn.fnamemodify(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)), ':~:.')
  -- local Path = require('plenary.path')
  --
  -- local blah = Path:new(filename)
  -- vim.notify(blah:shorten(3, { -1, -2 }))

  -- -- Get the current buffer number
  -- local bufnr = vim.api.nvim_get_current_buf()
  --
  -- -- Get the cursor position
  -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  -- row = row - 1 -- API uses 0-based row numbers
  --
  -- -- Get the syntax ID at the cursor position
  -- local syntax_id = vim.fn.synID(row + 1, col + 1, 1)
  --
  -- -- Get the name of the syntax group
  -- local syntax_name = vim.fn.synIDattr(syntax_id, 'name')
  --
  -- -- Get the linked highlight group
  -- local linked_hl_group = vim.fn.synIDattr(vim.fn.synIDtrans(syntax_id), 'name')
  --
  -- -- Print the results
  -- vim.notify('Syntax group: ' .. syntax_name)
  -- vim.notify('Linked highlight group: ' .. linked_hl_group)
end, { desc = 'debugging function' })

-- vim: ts=2 sts=2 sw=2 et
