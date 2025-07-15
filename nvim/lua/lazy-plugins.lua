require('lazy').setup(

  ---@module 'lazy'
  ---@type LazySpec
  {
    { import = 'plugins' },
    {
      import = 'plugins/dev',
      cond = function() return vim.g.plugins_dev end,
    },
    {
      import = 'plugins/extra',
      cond = function() return vim.g.plugins_extra end,
    },
    {
      import = 'plugins/fun',
      cond = function() return vim.g.plugins_fun end,
    },
    {
      import = 'plugins/compat',
      cond = function() return vim.fn.has('nvim-0.11') == 0 end,
    },
  },

  ---@module 'lazy'
  ---@type LazyConfig
  {
    ui = {
      -- If you are using a Nerd Font: set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🗝',
        plugin = '🔌',
        runtime = '💻',
        require = '🌙',
        source = '📄',
        start = '🚀',
        task = '📌',
        lazy = '💤 ',
      },
      size = { width = 0.8, height = 0.8 },
      border = 'rounded',
    },
    install = {
      colorscheme = { 'tokyonight' },
    },
    checker = {
      enabled = true,
      notify = false,
      frequency = 3600,
    },
    performance = {
      rtp = {
        ---@type string[] list any plugins you want to disable here
        disabled_plugins = {
          -- 'matchparen',
          -- "netrwPlugin",
          -- 'gzip',
          -- 'tarPlugin',
          -- 'zipPlugin',
          -- 'tohtml',
        },
      },
    },
    dev = {
      path = '~/Dev/neovim-dev/',
      fallback = false,
    },
  }
)

-- vim: ts=2 sts=2 sw=2 et
