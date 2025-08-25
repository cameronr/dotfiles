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

-- Default to main branch of treesitter if we have a build environment and tree-sitter
local default_treesitter_branch = (vim.fn.executable('make') == 1 and vim.fn.executable('tree-sitter') == 1) and 'main' or 'master'
-- But allow env var override
vim.g.treesitter_branch = vim.env.NVIM_TREESITTER_BRANCH or default_treesitter_branch

-- [[ Setting options ]]
require('options')

-- [[ Basic Keymaps ]]
require('keymaps')

-- [[ General Autocmds ]]
require('autocmds')

-- [[ Install `lazy.nvim` plugin manager ]]
require('lazy-bootstrap')

-- [[ Configure and install plugins ]]
require('lazy-plugins')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
