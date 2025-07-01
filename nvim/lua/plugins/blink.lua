return {
  {
    'saghen/blink.cmp',
    enabled = vim.g.cmp_engine ~= 'cmp',

    -- lazy = false, -- lazy loading handled internally
    event = { 'InsertEnter', 'CmdlineEnter' },

    -- optional: provides snippets for the snippet source
    dependencies = {
      'rafamadriz/friendly-snippets',
    },

    -- use a release tag to download pre-built binaries
    version = 'v1.*',
    -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- see the "default configuration" section below for full documentation on how to define
      -- your own keymap.

      keymap = {
        preset = 'default',

        ['<M-space>'] = { 'show_signature', 'hide_signature' },
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<Up>'] = {},
        ['<Down>'] = {},
      },

      --     keymap = {
      --       show = '<C-space>',
      --       hide = '<C-e>',
      --       accept = '<CR>',
      --       select_prev = { '<S-Tab>', '<C-k>' },
      --       select_next = { '<Tab>', '<C-j>' },
      --
      --       show_documentation = {},
      --       hide_documentation = {},
      --       scroll_documentation_up = '<C-b>',
      --       scroll_documentation_down = '<C-f>',
      --
      --       snippet_forward = '<Tab>',
      --       snippet_backward = '<S-Tab>',
      --     },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        -- use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
        kind_icons = {
          Array = ' ',
          Boolean = '󰨙 ',
          Class = ' ',
          Codeium = '󰘦 ',
          Color = ' ',
          Control = ' ',
          Collapsed = ' ',
          Constant = '󰏿 ',
          Constructor = ' ',
          Copilot = ' ',
          Enum = ' ',
          EnumMember = ' ',
          Event = ' ',
          Field = ' ',
          File = ' ',
          Folder = ' ',
          Function = '󰊕 ',
          Interface = ' ',
          Key = ' ',
          Keyword = ' ',
          Method = '󰊕 ',
          Module = ' ',
          Namespace = '󰦮 ',
          Null = ' ',
          Number = '󰎠 ',
          Object = ' ',
          Operator = ' ',
          Package = ' ',
          Property = ' ',
          Reference = ' ',
          Snippet = '󱄽 ',
          String = ' ',
          Struct = '󰆼 ',
          Supermaven = ' ',
          TabNine = '󰏚 ',
          Text = ' ',
          TypeParameter = ' ',
          Unit = ' ',
          Value = ' ',
          Variable = '󰀫 ',
        },
      },

      -- Default sources here to be extended with plugins later in the conf
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      cmdline = {
        -- keymap = {
        -- ['<CR>'] = { 'accept', 'fallback' },
        -- },
        completion = {
          list = {
            selection = { preselect = false, auto_insert = true },
          },
          menu = { auto_show = true },
        },
      },

      completion = {
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        menu = {
          border = 'rounded',
          max_height = 15,

          -- Min width not supported with right alignment
          -- https://github.com/Saghen/blink.cmp/issues/424
          -- min_width = 30,
          draw = {
            columns = {
              { 'kind_icon' },
              { 'label', 'label_description', 'source_name', gap = 1 },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  if ctx.source_id == 'cmdline' then return end
                  return ctx.kind_icon .. ctx.icon_gap
                end,
              },
              source_name = {
                text = function(ctx)
                  if ctx.source_id == 'cmdline' then return end
                  return ctx.source_name:sub(1, 4)
                end,
              },
            },

            -- for highlighting in completion menu
            treesitter = {
              'lsp',
            },
          },
        },

        documentation = {
          auto_show = true,
          window = {
            border = 'rounded',
          },
        },
      },

      -- experimental signature help support
      -- only trigger manually
      signature = {
        enabled = true,
        trigger = {
          enabled = true,
          show_on_trigger_character = false,
          show_on_insert_on_trigger_character = false,
        },
        window = {
          show_documentation = true,
          border = 'rounded',
        },
      },
    },
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = {
      'sources.default',
    },
  },

  -- lazydev
  {
    'saghen/blink.cmp',
    opts = {
      sources = {
        -- add lazydev to your completion providers
        default = { 'lazydev' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100, -- show at a higher priority than lsp
          },
        },
      },
    },
  },

  {
    'Kaiser-Yang/blink-cmp-git',
    lazy = true,
    enabled = vim.g.cmp_engine ~= 'cmp',
  },
  {
    'saghen/blink.cmp',
    opts = {
      sources = {
        -- add lazydev to your completion providers
        default = { 'git' },
        providers = {
          git = {
            module = 'blink-cmp-git',
            name = 'Git',
            should_show_items = function() return vim.o.filetype == 'gitcommit' or vim.o.filetype == 'markdown' end,
            opts = {
              use_items_pre_cache = false,
              -- options for the blink-cmp-git
            },
          },
        },
      },
    },
  },
  {
    'saghen/blink.cmp',
    dependencies = {
      'mgalliou/blink-cmp-tmux',
    },
    opts = function(_, opts)
      if Snacks then
        ---@diagnostic disable-next-line: undefined-field
        Snacks.toggle({
          name = 'Blink tmux source',
          get = function() return vim.g.custom_blink_cmp_tmux_enabled end,
          ---@diagnostic disable-next-line: inject-field
          set = function(state) vim.g.custom_blink_cmp_tmux_enabled = state end,
        }):map('<leader>vT')
      end

      -- Don't want to replace sources but add to it
      table.insert(opts.sources.default, 'tmux')

      return vim.tbl_deep_extend('force', opts or {}, {
        sources = {
          providers = {
            tmux = {
              enabled = function() return vim.g.custom_blink_cmp_tmux_enabled end,
              module = 'blink-cmp-tmux',
              name = 'tmux',
              -- default options
              opts = {
                all_panes = true,
                capture_history = false,
                -- only suggest completions from `tmux` if the `trigger_chars` are
                -- used
                -- triggered_only = false,
                -- trigger_chars = { '.' },
              },
            },
          },
        },
      })
    end,
  },

  ---@module "lazy"
  ---@type LazySpec
  {
    'saghen/blink.cmp',
    dependencies = {
      'mikavilpas/blink-ripgrep.nvim',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = {
          'ripgrep',
        },
        providers = {
          ripgrep = {
            module = 'blink-ripgrep',
            name = 'Ripgrep',
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              mode = 'off', -- default to off
              prefix_min_len = 5,
              toggles = {
                on_off = '<leader>vG',
              },
            },
          },
        },
      },
    },
  },
}
