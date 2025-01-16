return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    keys = function()
      local keys = {
        { '[l', function() Snacks.words.jump(-1, true) end, desc = 'Next LSP highlight' },
        { ']l', function() Snacks.words.jump(1, true) end, desc = 'Next LSP highlight' },
        { '<leader>cc', function() Snacks.scratch() end, desc = 'Scratch pad' },
        { '<leader>cC', function() Snacks.scratch.select() end, desc = 'Select scratch pad' },
        { '<leader>sp', function() Snacks.notifier.show_history({ reverse = true }) end, desc = 'Search popups' },
        { '<leader>wp', function() Snacks.notifier.hide() end, desc = 'Dismiss popups' },
      }
      if vim.g.picker_engine ~= 'snacks' then return keys end

      local picker_keys = {
        { '<leader><leader>', function() Snacks.picker.buffers() end, desc = 'Buffers' },
        { '<leader>/', function() Snacks.picker.grep() end, desc = 'Grep' },
        { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
        { '<leader>sf', function() Snacks.picker.files() end, desc = 'Find Files' },
        -- find
        { '<leader>sb', function() Snacks.picker.pickers() end, desc = 'Pickers' },
        { '<leader>sgf', function() Snacks.picker.git_files() end, desc = 'Find Git Files' },
        { '<leader>s.', function() Snacks.picker.recent() end, desc = 'Recent' },
        -- git
        { '<leader>sgc', function() Snacks.picker.git_log() end, desc = 'Git Log' },
        { '<leader>sgs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
        -- Grep
        { '<leader>sz', function() Snacks.picker.lines() end, desc = 'Fuzzy find in buffer' },
        { '<leader>sB', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
        { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Visual selection or word', mode = { 'n', 'x' } },
        -- search
        { '<leader>s"', function() Snacks.picker.registers() end, desc = 'Registers' },
        { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
        { '<leader>sc', function() Snacks.picker.command_history() end, desc = 'Command History' },
        { '<leader>sv', function() Snacks.picker.commands() end, desc = 'Commands' },
        { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
        { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
        { '<leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
        { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
        { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
        { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
        { '<leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
        { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
        { '<leader>sR', function() Snacks.picker.resume() end, desc = 'Resume' },
        { '<leader>sq', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },
        { '<leader>sC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
        { '<leader>qp', function() Snacks.picker.projects() end, desc = 'Projects' },
        -- LSP
        { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
        { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
        { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
        { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition' },
        { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
      }

      keys = vim.tbl_deep_extend('force', keys, picker_keys)
      return keys
    end,
    opts = {
      debug = { enabled = true },
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      input = { enabled = true },
      notifier = {
        enabled = true,
        style = 'fancy',
        level = vim.log.levels.INFO,
      },
      picker = {
        enabled = vim.g.picker_engine == 'snacks',
        formatters = {
          file = {
            filename_first = true, -- display filename before the file path
          },
        },
        layout = {
          cycle = true,
          --- Use the default layout or vertical if the window is too narrow
          preset = function() return vim.o.columns >= 120 and 'telescope' or 'vertical' end,
        },
        win = {
          -- input window
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              ['<C-_>'] = { 'toggle_help', mode = { 'n', 'i' } },
              ['<c-p>'] = { 'toggle_preview', mode = { 'i', 'n' } },
              ['<pagedown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
              ['<pageup>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
            },
          },
        },
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
          Snacks.toggle.indent():map('<leader>vi')

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
  {
    'folke/trouble.nvim',
    optional = true,
    specs = {
      'folke/snacks.nvim',
      opts = function(_, opts)
        return vim.tbl_deep_extend('force', opts or {}, {
          picker = {
            actions = require('trouble.sources.snacks').actions,
            win = {
              input = {
                keys = {
                  ['<c-t>'] = { 'trouble_open', mode = { 'n', 'i' } },
                },
              },
            },
          },
        })
      end,
    },
  },
}
