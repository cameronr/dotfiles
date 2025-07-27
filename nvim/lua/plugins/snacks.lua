return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    keys = function()
      local keys = {
        { '[l', function() Snacks.words.jump(-1, true) end, desc = 'Prev LSP highlight' },
        { ']l', function() Snacks.words.jump(1, true) end, desc = 'Next LSP highlight' },
        { '<leader>cc', function() Snacks.scratch() end, desc = 'Scratch pad' },
        { '<leader>cC', function() Snacks.scratch.select() end, desc = 'Select scratch pad' },
        { '<leader>cP', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Buffer' },
        { '<leader>sp', function() Snacks.notifier.show_history({ reverse = true }) end, desc = 'Show notifs' },
        { '<leader>wp', function() Snacks.notifier.hide() end, desc = 'Dismiss popups' },
        { '<leader>e', function() Snacks.picker.explorer() end, desc = 'Explorer' },
        { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Close buffer' },
      }
      if vim.g.picker_engine ~= 'snacks' then return keys end

      local picker_keys = {
        { '<leader><leader>', function() Snacks.picker.buffers() end, desc = 'Buffers' },
        { '<leader>/', function() Snacks.picker.grep() end, desc = 'Grep' },
        { '<leader>:', function() Snacks.picker.command_history({ layout = { preset = 'select' } }) end, desc = 'Command History' },
        { '<leader>sf', function() Snacks.picker.files() end, desc = 'Find Files' },
        -- find
        { '<leader>sB', function() Snacks.picker.pickers() end, desc = 'Pickers' },
        { '<leader>sG', function() Snacks.picker.git_files() end, desc = 'Find Git Files' },
        { '<leader>s.', function() Snacks.picker.recent() end, desc = 'Recent' },
        -- git
        { '<leader>sgc', function() Snacks.picker.git_log() end, desc = 'Git Log' },
        { '<leader>sgl', function() Snacks.picker.git_log() end, desc = 'Git Log' },
        { '<leader>sgL', function() Snacks.picker.git_log_line() end, desc = 'Git Log Line' },
        { '<leader>sgf', function() Snacks.picker.git_log_file() end, desc = 'Git Log File' },
        { '<leader>sgs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
        { '<leader>sgb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },
        { '<leader>sgz', function() Snacks.picker.git_stash() end, desc = 'Git Stash' },
        { 'gX', function() Snacks.gitbrowse() end, desc = 'Git browse', mode = { 'n', 'x' } },
        -- Grep
        { '<leader>sz', function() Snacks.picker.lines() end, desc = 'Fuzzy find in buffer' },
        { '<leader>sb', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
        { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Visual selection or word', mode = { 'n', 'x' } },
        -- search
        { '<leader>s"', function() Snacks.picker.registers() end, desc = 'Registers' },
        { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
        { '<leader>sc', function() Snacks.picker.command_history({ layout = { preset = 'select' } }) end, desc = 'Command History' },
        { '<leader>sv', function() Snacks.picker.commands() end, desc = 'Commands' },
        { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
        { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
        { '<leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
        { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
        { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
        { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
        { '<leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
        { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
        { "<leader>s'", function() Snacks.picker.marks() end, desc = 'Marks' },
        { '<leader>sr', function() Snacks.picker.resume() end, desc = 'Resume search' },
        { '<leader>.', function() Snacks.picker.resume() end, desc = 'Resume search' },
        { '<leader>sq', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },
        { '<leader>sC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
        { '<leader>su', function() Snacks.picker.undo() end, desc = 'Undotree' },
        { '<leader>u', function() Snacks.picker.undo() end, desc = 'Undotree' },
        -- { '<leader>qp', function() Snacks.picker.projects() end, desc = 'Projects' },
        -- LSP
        { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Definition' },
        { 'grd', function() Snacks.picker.lsp_definitions() end, desc = 'Definition' },
        { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
        { 'grr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
        { 'gri', function() Snacks.picker.lsp_implementations() end, desc = 'Implementation' },
        { 'grt', function() Snacks.picker.lsp_type_definitions() end, desc = 'Type Definition' },
        -- gO
        -- gW
        { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
        { 'gO', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
        { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },
        { 'gW', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },

        -- Notifications
        { '<leader>sP', function() Snacks.picker.notifications() end, desc = 'Search notifs' },
      }

      for _, entry in ipairs(picker_keys) do
        table.insert(keys, entry)
      end

      return keys
    end,

    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      debug = { enabled = true },
      explorer = {},
      indent = {
        enabled = true,
        animate = { enabled = false },
        filter = function(buf)
          local no_indent_fts = {
            'gitcommit',
          }
          return vim.g.snacks_indent ~= false
            and vim.b[buf].snacks_indent ~= false
            and vim.bo[buf].buftype == ''
            and not vim.tbl_contains(no_indent_fts, vim.bo[buf].filetype)
        end,
      },
      input = { enabled = true },
      notifier = {
        enabled = true,
        style = 'fancy',
      },
      picker = {
        enabled = vim.g.picker_engine == 'snacks',
        formatters = {
          file = {
            filename_first = true,
          },
        },
        layout = function()
          --- Use the vertical layout if screen is small
          if vim.o.columns < 120 then return { cycle = true, preset = 'vertical' } end

          -- NOTE: I went back and forth on this. I could just duplicate the text of the
          -- telescope preset here but then I wouldn't get any updates if it changed.
          -- Instead, we make a copy of the preset and tweak a few values. I'm not sure
          -- if that's better but here it is
          -- One side benefit of using a function instead of an actual table is that
          -- Snacks won't merge this layout with a custom set picker layout like it
          -- would if it were just a table
          local telescope = vim.deepcopy(require('snacks.picker.config.layouts').telescope)

          -- enable backdrop
          telescope.layout['backdrop'] = nil

          -- find the preview box element and make it slightly larger
          for _, elem in ipairs(telescope.layout) do
            if type(elem) == 'table' and elem['win'] == 'preview' then elem['width'] = 0.52 end
          end
          return telescope
        end,
        win = {
          -- input window
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              ['<C-_>'] = { 'toggle_help', mode = { 'n', 'i' } },
              ['<c-p>'] = { 'toggle_preview', mode = { 'i', 'n' } },
              ['<pagedown>'] = { 'list_scroll_down', mode = { 'i', 'n' } },
              ['<pageup>'] = { 'list_scroll_up', mode = { 'i', 'n' } },
              ['<a-d>'] = { 'bufdelete', mode = { 'i', 'n' } },
            },
          },
        },

        sources = {
          marks = {
            actions = {
              delmark = function(picker)
                local cursor = picker.list.cursor
                local deleted = {}
                for _, it in ipairs(picker:selected({ fallback = true })) do
                  local success
                  if it.label:match('[a-z]') then
                    success = vim.api.nvim_buf_del_mark(it.buf, it.label)
                  else
                    success = vim.api.nvim_del_mark(it.label)
                  end
                  if success then table.insert(deleted, it) end
                end

                picker:close()
                local picker_new = Snacks.picker.marks()
                picker_new.list:view(cursor - #deleted)
              end,
            },
            win = {
              input = {
                keys = {
                  ['<a-d>'] = { 'delmark', mode = { 'i', 'n' } }, -- Bind "a-d" in input and normal mode
                },
              },
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
            { icon = '󰊢 ', key = 'n', desc = 'Neogit', action = ':Neogit', enabled = function() return vim.fn.exists(':Neogit') == 2 end },
            { icon = ' ', key = 'o', desc = 'Obsidian', action = ':Obsidian search', enabled = function() return vim.fn.exists(':Obsidian') == 2 end },
            { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
            { icon = ' ', key = 'm', desc = 'Mason', action = ':Mason' },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
        sections = {
          function()
            if vim.fn.has('win32') == 1 or vim.fn.executable('lolcrab') == 0 or vim.env.NVIM_NO_LOLCRAB then return { section = 'header' } end

            return {
              section = 'terminal',
              cmd = '{cat '
                .. vim.fn.stdpath('config')
                .. '/logo.txt; echo "                                           '
                .. vim.version().major
                .. '.'
                .. vim.version().minor
                .. '.'
                .. vim.version().patch
                .. '"} | lolcrab; sleep .01',
              height = 8,
              align = 'center',
              indent = 5,
              padding = 0,
            }
          end,

          { section = 'keys', gap = 1, padding = 1 },
          { section = 'startup' },
        },
      },

      -- dashboard = {
      --   enabled = true,
      --   preset = {
      --     header = [[
      --  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
      --  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
      --  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
      --  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
      --  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
      --  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      --                                       ]] .. vim.version().major .. '.' .. vim.version().minor .. '.' .. vim.version().patch,
      --     keys = {
      --       { icon = ' ', key = 'f', desc = 'Find file', action = ":lua Snacks.dashboard.pick('files')" },
      --       { icon = ' ', key = 'g', desc = 'Find text', action = ":lua Snacks.dashboard.pick('live_grep')" },
      --       { icon = ' ', key = 'e', desc = 'New file', action = ':ene' },
      --       { icon = ' ', key = 'r', desc = 'Recent files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
      --       { icon = '󰁯 ', key = 'w', desc = 'Restore session', action = ':SessionSearch' },
      --       { icon = '󰊢 ', key = 'n', desc = 'Neogit', action = ':Neogit' },
      --       { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
      --       { icon = ' ', key = 'm', desc = 'Mason', action = ':Mason' },
      --       { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      --     },
      --   },
      -- },

      styles = {
        notification_history = {
          keys = { ['<esc>'] = 'close' },
        },
        input = {
          keys = {
            i_esc = { '<esc>', { 'cmp_close', 'close' }, mode = 'i', expr = true },
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
          Snacks.toggle.option('cursorline', { name = 'cursorline' }):map('<leader>vC')
          Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = 'Conceal Level' }):map('<leader>vc')
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
    optional = true,
    opts = function(_, opts)
      if Snacks then table.insert(opts.sections.lualine_x, Snacks.profiler.status()) end
    end,
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
