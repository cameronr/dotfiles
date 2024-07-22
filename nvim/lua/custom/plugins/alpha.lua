return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  config = function()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')
    local version = vim.version()

    -- Set header
    dashboard.section.header.val = {
      '                                                     ',
      '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
      '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
      '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
      '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
      '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
      '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
      '                                              ' .. version.major .. '.' .. version.minor .. '.' .. version.patch,
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button('e', '  New File', '<cmd>ene<CR>'),
      dashboard.button('f', '󰱼  Open Files', '<cmd>Telescope find_files<CR>'),
      dashboard.button('g', '  Grep in Files', '<cmd>Telescope live_grep<CR>'),
      dashboard.button('.', '󱑎  Recent Files', '<cmd>Telescope oldfiles <CR>'),
      dashboard.button('SPC n', '󰊢  Neogit'),
      dashboard.button('r', '󰁯  Restore a Session', "<cmd>lua require('auto-session.session-lens').search_session()<CR>"),
      -- dashboard.button('c', '󰁯  Restore Session For Current Directory', '<cmd>SessionRestore<CR>'),
      dashboard.button('l', '󰒲  Lazy', '<cmd>Lazy<CR>'),
      dashboard.button('m', '  Mason', '<cmd>Mason<CR>'),
      -- dashboard.button('c', '  Neovim configuration', '<cmd>cd ~/.config/nvim<CR> | <cmd>SessionRestore <CR>'),
      dashboard.button('q', '󰩈  Quit NVIM', '<cmd>qa<CR>'),
    }
    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl = 'AlphaButtons'
      button.opts.hl_shortcut = 'AlphaShortcut'
    end
    dashboard.section.header.opts.hl = 'AlphaHeader'
    dashboard.section.buttons.opts.hl = 'AlphaButtons'
    dashboard.section.footer.opts.hl = 'AlphaFooter'
    -- dashboard.opts.layout[1].val = 8

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Borrowed from LazyVim
    vim.api.nvim_create_autocmd('User', {
      once = true,
      pattern = 'LazyVimStarted',
      callback = function()
        local stats = require('lazy').stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        dashboard.section.footer.val = '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms'
        pcall(vim.cmd.AlphaRedraw)
      end,
    })

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
