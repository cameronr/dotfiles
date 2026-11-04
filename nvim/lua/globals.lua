-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)

if not vim.g.man_pager then
  vim.g.mapleader = ' '
  vim.g.maplocalleader = '\\'
end

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- If NVIM_NO_MASON_AUTOINSTALL is set, don't autoinstall any Mason modules
vim.g.no_mason_autoinstall = vim.env.NVIM_NO_MASON_AUTOINSTALL

-- Which finder engine to use
vim.g.picker_engine = vim.env.NVIM_PICKER_ENGINE or 'snacks'

-- Which completion engine to use
vim.g.cmp_engine = vim.env.NVIM_CMP_ENGINE or 'blink'

-- nvim-treesitter master is frozen and unsupported on nvim 0.11+ (it crashes on 0.12's
-- query API). main is the only supported path there; master stays for legacy nvim < 0.11.
local default_treesitter_branch = vim.fn.has('nvim-0.11') == 1 and 'main' or 'master'
-- But allow env var override
vim.g.treesitter_branch = vim.env.NVIM_TREESITTER_BRANCH or default_treesitter_branch

-- nvim-treesitter main compiles parsers with the `tree-sitter` CLI + a C compiler.
-- On boxes with no cc/gcc/clang but with zig, point CC at a zig-cc shim so
-- :TSUpdate / :TSInstall can still build parsers.
if
  vim.fn.executable('cc') == 0 and vim.fn.executable('gcc') == 0 and vim.fn.executable('clang') == 0
  and vim.fn.executable('zig') == 1
then
  vim.env.CC = vim.fn.stdpath('config') .. '/bin/zig-cc'
end

-- Use copilot
vim.g.use_copilot = vim.env.NVIM_USE_COPILOT == '1'
