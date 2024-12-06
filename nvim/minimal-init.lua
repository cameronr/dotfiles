-- stripped down, single file conifg with no plugin manager

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard:append('unnamedplus')

  -- Fix "waiting for osc52 response from terminal" message
  -- https://github.com/neovim/neovim/issues/28611

  if vim.env.SSH_TTY ~= nil then
    -- Set up clipboard for ssh

    local function my_paste(_)
      return function(_)
        local content = vim.fn.getreg('"')
        return vim.split(content, '\n')
      end
    end

    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        -- No OSC52 paste action since wezterm doesn't support it
        -- Should still paste from nvim
        ['+'] = my_paste('+'),
        ['*'] = my_paste('*'),
      },
    }
  end
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'nosplit'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 4

-- Don't autoinsert comments on o/O (but i still need the BufEnter at the bottom)
vim.opt.formatoptions:remove({ 'o' })

-- Really, really disable comment autoinsertion on o/O
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function() vim.opt_local.formatoptions:remove({ 'o' }) end,
  desc = 'Disable New Line Comment',
})

-- Wrap arrow keys
vim.opt.whichwrap:append('<,>,[,]')

-- Add characters to set used to identify words
vim.opt.iskeyword:append({ '-' })

vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  eob = ' ', -- Don't show ~ at end of buffer
  diff = '╱', -- Nicer background in DiffView
}

if vim.fn.has('nvim-0.10') == 1 then
  -- scroll virtual lines when wrapping is on rather than jumping a big
  -- block
  vim.opt.smoothscroll = true
end

-- Both of these from https://www.reddit.com/r/neovim/comments/1abd2cq/what_are_your_favorite_tricks_using_neovim/
-- Jump to last position when reopening a file
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  command = 'silent! normal! g`"zv',
})

-- Always open help on the right
-- Open help window in a vertical split to the right.
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('help_window_right', {}),
  pattern = { '*.txt' },
  callback = function()
    if vim.o.filetype == 'help' then vim.cmd.wincmd('L') end
  end,
})

-- Set default tab options (but they should be overridden by sleuth)
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.shiftround = true
vim.opt.smartindent = true

-- Recommended session options from auto-sessions
vim.opt.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Hide diagnostic virtual text and add border to floating window
vim.opt.wrap = true

-- options end

-- keymaps start

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

-- Unamp g? (don't need rot-13)
vim.keymap.set({ 'n', 'x' }, 'g?', '<nop>', { noremap = true })

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
vim.keymap.set({ 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr>', { desc = 'Save File' })

-- save file with undo point in insert mode
vim.keymap.set('i', '<C-s>', '<c-g>u<cmd>w<cr><esc>', { desc = 'Save File' })

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

vim.keymap.set('n', '<leader>vt', '<cmd>TSToggle highlight<CR>', { desc = 'Toggle Treesitter highlight' })
vim.keymap.set('n', '<leader>vh', '<cmd>nohl<CR>', { desc = 'Clear highlights' })
vim.keymap.set('n', '<leader>vr', vim.cmd.checktime, { desc = 'Refresh files' })

vim.keymap.set('n', '<leader>t', '<cmd>InspectTree<cr>', { desc = 'Inspect TS Tree' })

-- keymaps end

-- vim: ts=2 sts=2 sw=2 et
