-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

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
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'nosplit'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 4

-- Don't autoinsert comments on o/O (but i still need the BufEnter at the bottom)
vim.opt.formatoptions:remove({ 'o' })

local options_user_augroup = vim.api.nvim_create_augroup('options_user_augroup', {})

-- Really, really disable comment autoinsertion on o/O
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function() vim.opt_local.formatoptions:remove({ 'o' }) end,
  group = options_user_augroup,
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
  vim.o.smoothscroll = true

  -- Enable tree-sitter folding
  -- vim.o.foldmethod = 'expr'
  -- vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  -- vim.o.foldlevel = 99

  -- Was getting some nofold errors on session restore even when I didn't create any
  -- so comment this out for now
  -- vim.o.foldlevelstart = 99

  -- vim.o.foldcolumn = '0' -- hide column by default
end

if vim.fn.has('nvim-0.11') == 1 then
  -- Right aligns numbers with relative line nums when < 100 lines
  -- I played with putting the sign column on the right side but the sign column
  -- is two columns wide and the characters for todos/diagnostics don't leave enough
  -- space on the left. If the sign column could be a single column wide, I'd be ok
  -- with what LazyVim does and have a sign column on the right for just gitsigns and another
  -- on the left for diagnostics but giving up 4 columns is too much.

  -- Disabled for 0.10 because we get line numbers on buffers that shouldn't have them (e.g. help)

  vim.o.statuscolumn = '%C%s%=%{v:relnum?v:relnum:v:lnum} '

  -- For 0.10, we need to check and see that vim.wo.number or vim.wo.relativenumber are true first
  -- otherwise we'll get numbers on buffers that shouldn't have them (e.g. help, alpha)
  -- vim.o.statuscolumn = "%C%s%=%{%(&number || &relativenumber) ? '%{v:relnum?v:relnum:v:lnum}' : ''%} "
end

-- Both of these from https://www.reddit.com/r/neovim/comments/1abd2cq/what_are_your_favorite_tricks_using_neovim/
-- Jump to last position when reopening a file
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  group = options_user_augroup,
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
  group = options_user_augroup,
  pattern = { '*.txt' },
  callback = function()
    if vim.o.filetype == 'help' then vim.cmd.wincmd('L') end
  end,
})

-- Set default tab options (but they should be overridden by guess-indent)
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.shiftround = true
vim.o.smartindent = true

-- Recommended session options from auto-sessions
vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- signcolumn on right exploration. ultimately, i like the numbers closers than the signs
-- vim.o.statuscolumn = "%=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '' : v:lnum) : ''} %s"

-- Enable wrapping of long lines and linebreak on words
vim.o.wrap = true
vim.o.linebreak = true

-- Preserve view when using jumplist and remove unloaded buffers (experimental)
vim.o.jumpoptions = 'view,clean'

if vim.fn.has('nvim-0.11') == 1 then
  -- Rounded borders by default on >= 0.11

  -- Commenting out because of snacks.dashboard
  -- vim.o.winborder = 'rounded'
end

-- vim: ts=2 sts=2 sw=2 et
