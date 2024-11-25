return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = 'VeryLazy',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      { 'folke/ts-comments.nvim', opts = {}, enabled = vim.fn.has('nvim-0.10.0') == 1 },
    },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'gitcommit',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = {
        enable = true,
        disable = { 'ruby' },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        move = {
          enable = true,
          -- don't include classes to not conflict with conflicts in a diff
          -- (LazyVim has some clever code but i don't think we need it right now)
          -- goto_next_start = { [']f'] = '@function.outer', [']c'] = '@class.outer', [']a'] = '@parameter.inner' },
          -- goto_next_end = { [']F'] = '@function.outer', [']C'] = '@class.outer', [']A'] = '@parameter.inner' },
          -- goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer', ['[a'] = '@parameter.inner' },
          -- goto_previous_end = { ['[F'] = '@function.outer', ['[C'] = '@class.outer', ['[A'] = '@parameter.inner' },
          goto_next_start = {
            [']f'] = '@function.outer',
            [']a'] = '@parameter.inner',
            [']s'] = '@block.outer',
            -- [']s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next scope' },
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']A'] = '@parameter.inner',
            [']S'] = '@block.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[a'] = '@parameter.inner',
            ['[s'] = '@block.outer',
            -- ['[s'] = { query = '@local.scope', query_group = 'locals', desc = 'Next scope' },
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[A'] = '@parameter.inner',
            ['[S'] = '@block.outer',
          },
        },
      },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
}
-- vim: ts=2 sts=2 sw=2 et
