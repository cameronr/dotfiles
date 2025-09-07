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

-- Set in case auto-detection fails
vim.o.termguicolors = true

-- Tokyonight "night" palette (distilled)
local palette = {
  bg = '#1a1b26',
  bg_dark = '#171821',
  fg = '#c0caf5',
  gray1 = '#565f89',
  gray2 = '#3b4261',
  gray3 = '#1f2335',
  orange = '#ff9e64',
  magenta = '#bb9af7',
  blue = '#7aa2f7',
  blue2 = '#2ac3de',
  green = '#9ece6a',
  green1 = '#73daca',
  yellow = '#e0af68',
  red = '#f7768e',
  cyan = '#7dcfff',
  purple = '#9d7cd8',
  purple2 = '#2d213d',
}

local function hi(group, opts) vim.api.nvim_set_hl(0, group, opts) end

-- Core UI
hi('Normal', { fg = palette.fg, bg = palette.bg })
hi('Comment', { fg = palette.gray1, italic = true })
hi('LineNr', { fg = palette.gray2 })
hi('CursorLine', { bg = palette.gray3 })
hi('CursorLineNr', { fg = palette.orange, bold = true })
hi('Special', { fg = palette.blue2 })
hi('Visual', { bg = palette.purple2 })

-- Syntax
hi('Keyword', { fg = palette.magenta })
hi('Function', { fg = palette.blue })
hi('String', { fg = palette.green })
hi('Constant', { fg = palette.orange })
hi('@variable.parameter', { fg = palette.yellow })
hi('@variable.member', { fg = palette.green1 })
hi('@variable.property', { fg = palette.green1 })
hi('@variable', { fg = palette.fg })

-- Diagnostics
hi('DiagnosticError', { fg = palette.red })
hi('DiagnosticWarn', { fg = palette.yellow })
hi('DiagnosticInfo', { fg = palette.cyan })
hi('DiagnosticHint', { fg = palette.purple })

-- Statusline highlight groups
hi('StatusLine', { fg = palette.fg, bg = palette.bg_dark })
hi('StatusLineNC', { fg = palette.gray1, bg = palette.bg_dark })
hi('StatusLineModeNormal', { fg = palette.bg, bg = palette.blue, bold = true })
hi('StatusLineModeInsert', { fg = palette.bg, bg = palette.green, bold = true })
hi('StatusLineModeVisual', { fg = palette.bg, bg = palette.purple, bold = true })
hi('StatusLineModeReplace', { fg = palette.bg, bg = palette.red, bold = true })
hi('StatusLineModeCommand', { fg = palette.bg, bg = palette.yellow, bold = true })
hi('StatusLineModeTerminal', { fg = palette.bg, bg = palette.green1, bold = true })

local mode_colors = {
  n = '%#StatusLineModeNormal# NORMAL ',
  i = '%#StatusLineModeInsert# INSERT ',
  v = '%#StatusLineModeVisual# VISUAL ',
  V = '%#StatusLineModeVisual# V-LINE ',
  ['\22'] = '%#StatusLineModeVisual# V-BLOCK ', -- <C-v>
  R = '%#StatusLineModeReplace# REPLACE ',
  c = '%#StatusLineModeCommand# COMMAND ',
  t = '%#StatusLineModeTerminal# TERMINAL ',
}

local function statusline_mode()
  local mode = ''
  if vim.g.statusline_winid == vim.api.nvim_get_current_win() then
    local m = vim.api.nvim_get_mode().mode:sub(1, 1)
    mode = (mode_colors[m] or ('%#StatusLineModeNormal# ' .. m)) .. ' %#StatusLine#'
  end
  return table.concat({ mode, ' %f %m %r', '%=', ' %y %p%% %l:%c ' })
end

-- Expose Lua function to statusline
_G.statusline_mode = statusline_mode

-- Set the statusline
-- Have to use %! to be able to test for statusline_winid
vim.o.statusline = '%!v:lua.statusline_mode()'
