return {

  ---@module "lazy"
  ---@type LazySpec
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = {
      'Kaiser-Yang/blink-cmp-git',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        -- add lazydev to your completion providers
        default = { 'git' },
        providers = {
          git = {
            module = 'blink-cmp-git',
            name = 'Git',
            should_show_items = function() return vim.o.filetype == 'gitcommit' or vim.o.filetype == 'markdown' end,
            max_items = 7,
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
    optional = true,
    dependencies = {
      'mgalliou/blink-cmp-tmux',
    },
    opts = function(_, opts)
      if Snacks then
        ---@diagnostic disable-next-line: undefined-field
        Snacks.toggle({
          name = 'blink-tmux',
          get = function() return vim.g.custom_blink_cmp_tmux_enabled end,
          ---@diagnostic disable-next-line: inject-field
          set = function(state) vim.g.custom_blink_cmp_tmux_enabled = state end,
        }):map('<leader>vT')
      end

      -- Don't want to replace sources but add to it
      table.insert(opts.sources.default, 'tmux')

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      return vim.tbl_deep_extend('force', opts or {}, {
        sources = {
          providers = {
            tmux = {
              enabled = function() return vim.g.custom_blink_cmp_tmux_enabled end,
              module = 'blink-cmp-tmux',
              name = 'tmux',
              max_items = 3,
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
    optional = true,
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
            max_items = 3,
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
