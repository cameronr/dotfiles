return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    keys = {
      { '[l', function() Snacks.words.jump(-1, true) end, desc = 'Next LSP highlight' },
      { ']l', function() Snacks.words.jump(1, true) end, desc = 'Next LSP highlight' },
      { '<leader>cc', function() Snacks.scratch() end, desc = 'Scratch pad' },
      { '<leader>cC', function() Snacks.scratch.select() end, desc = 'Select scratch pad' },
      { '<leader>sp', function() Snacks.notifier.show_history({ reverse = true }) end, desc = 'Search popups' },
      { '<leader>wp', function() Snacks.notifier.hide() end, desc = 'Dismiss popups' },
    },
    opts = {
      debug = { enabled = true },
      indent = {
        enabled = true,
        scope = {
          animate = { enabled = false },
        },
      },
      input = { enabled = true },
      notifier = {
        enabled = true,
        style = 'fancy',
        level = vim.log.levels.INFO,
      },
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
      styles = {
        ['notification.history'] = {
          keys = { ['<esc>'] = 'close' },
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

          -- Toggle the profiler
          Snacks.toggle.profiler():map('<leader>cp')
          -- Toggle the profiler highlights
          Snacks.toggle.profiler_highlights():map('<leader>vP')
        end,
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = function(_, opts) table.insert(opts.sections.lualine_x, Snacks.profiler.status()) end,
  },
}
