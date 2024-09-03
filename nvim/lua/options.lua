-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

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
vim.opt.scrolloff = 8

-- Don't autoinsert comments on o/O (but i still need the BufEnter at the bottom)
vim.opt.formatoptions:remove({ 'o' })

-- Really, really disable comment autoinsertion on o/O
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function() vim.opt.formatoptions:remove({ 'o' }) end,
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

  -- Enable tree-sitter folding
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.opt.foldlevel = 99
  vim.opt.foldlevelstart = 99
  vim.opt.foldcolumn = '0' -- hide column by default
end

-- Both of these from https://www.reddit.com/r/neovim/comments/1abd2cq/what_are_your_favorite_tricks_using_neovim/
-- Jump to last position when reopening a file
-- vim.api.nvim_create_autocmd('BufReadPost', {
--   desc = 'Open file at the last position it was edited earlier',
--   group = misc_augroup,
--   pattern = '*',
--   command = 'silent! normal! g`"zv',
-- })

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then vim.api.nvim_win_set_cursor(0, mark) end
  end,
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
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.shiftround = true
vim.o.smartindent = true

-- Recommended session options from auto-sessions
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Hide diagnostic virtual text and add border to floating window
vim.diagnostic.config({
  virtual_text = false,
  float = {
    -- header = false,
    border = 'rounded',
  },
})

vim.opt.wrap = true

-- vim: ts=2 sts=2 sw=2 et
