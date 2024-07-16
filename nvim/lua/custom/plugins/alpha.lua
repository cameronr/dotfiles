return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  config = function()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')

    -- Set header
    dashboard.section.header.val = {
      '                                                     ',
      '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
      '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
      '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
      '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
      '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
      '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
      '                                                     ',
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button('e', '  New File', '<cmd>ene<CR>'),
      dashboard.button('SPC sf', '󰱼  Open Files'),
      dashboard.button('SPC sg', '  Search files'),
      dashboard.button('SPC s.', '󱑎  Recent Files'),
      dashboard.button('SPC n', '󰊢  Neogit'),
      dashboard.button('r', '󰁯  Restore a Session', "<cmd>lua require('auto-session.session-lens').search_session()<CR>"),
      -- dashboard.button('c', '󰁯  Restore Session For Current Directory', '<cmd>SessionRestore<CR>'),
      dashboard.button('l', '󰒲  Lazy', '<cmd>Lazy<CR>'),
      dashboard.button('m', '  Mason', '<cmd>Mason<CR>'),
      dashboard.button('c', '  Neovim configuration', '<cmd>cd ~/.config/nvim<CR> | <cmd>SessionRestore <CR>'),
      dashboard.button('q', '󰩈  Quit NVIM', '<cmd>qa<CR>'),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
