---Get env value, with default
---@param env_var_name string
---@param default? boolean
---@return boolean
local function get_env(env_var_name, default)
  default = default or false
  local value = os.getenv(env_var_name)
  if not value then return default end
  value = value:lower()
  return value == 'true' or value == '1' or value == 'yes' or value == 'on'
end

require('lazy').setup(

  ---@module 'lazy'
  ---@type LazySpec
  {
    { import = 'plugins' },
    {
      import = 'plugins/dev',
      cond = get_env('NVIM_PLUGINS_DEV', true),
    },
    {
      import = 'plugins/extra',
      cond = get_env('NVIM_PLUGINS_EXTRA'),
    },
    {
      import = 'plugins/fun',
      cond = get_env('NVIM_PLUGINS_FUN'),
    },
    {
      import = 'plugins/compat',
      cond = vim.fn.has('nvim-0.11') == 0,
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
