return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  keys = {
    { '[l', function() require('snacks').words.jump(-1, true) end, desc = 'Next LSP highlight' },
    { ']l', function() require('snacks').words.jump(1, true) end, desc = 'Next LSP highlight' },
  },
  opts = {
    debug = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                            ]] .. vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch,
        keys = {
          { icon = ' ', key = 'f', desc = 'Find file', action = ":lua Snacks.dashboard.pick('files')" },
          { icon = ' ', key = 'g', desc = 'Find text', action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = ' ', key = 'e', desc = 'New file', action = ':ene' },
          { icon = ' ', key = 'r', desc = 'Recent files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = '󰁯 ', key = 'w', desc = 'Restore session', action = ':SessionSearch' },
          { icon = '󰊢 ', key = 'n', desc = 'Neogit', action = ':Neogit' },
          { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
          { icon = ' ', key = 'm', desc = 'Mason', action = ':Mason' },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'dark background' }):map('<leader>vb')
        Snacks.toggle.option('foldcolumn', { off = '0', on = '1', name = 'foldcolumn' }):map('<leader>vz')
        Snacks.toggle.option('cursorline', { name = 'cursorline' }):map('<leader>vc')
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>vw')
        Snacks.toggle.inlay_hints():map('<leader>vH')
        Snacks.toggle.diagnostics():map('<leader>vd')
      end,
    })
  end,
}
