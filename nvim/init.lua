-- Set leader, localleader, globals from env vars
require('globals')

-- They shouldn't be called options... they should be called requirements
require('options')

-- Set default keymaps, may be overridden by plugins
require('keymaps')

-- Some QOL autocmds
require('autocmds')

-- Install lazy.nvim
require('lazy-bootstrap')

-- Configure and install plugins
require('lazy-plugins')

-- vim: ts=2 sts=2 sw=2 et
