return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>vF',
        ---@diagnostic disable-next-line: param-type-mismatch
        function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
        mode = '',
        desc = 'Format buffer',
      },
    },

    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = true,
      -- log_level = vim.log.levels.INFO,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort' },

        -- webdev (strictly using Biome)
        javascript = { 'biome' },
        typescript = { 'biome' },
        javascriptreact = { 'biome' },
        typescriptreact = { 'biome' },
        json = { 'biome' },
        jsonc = { 'biome' },
        css = { 'biome' },
        graphql = { 'biome' },

        -- languages not yet formatted by Biome (retained Prettier)
        svelte = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        liquid = { 'prettierd', 'prettier', stop_after_first = true },

        -- text
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        markdown = { 'prettierd', 'injected' },

        -- shell
        sh = { 'shfmt' },
        zsh = { 'beautysh' },

        -- sql
        sql = { 'sqruff' },
      },
      formatters = {
        beautysh = {
          prepend_args = { '--indent-size', '2' },
        },
        biome = {
          -- By default conform requires a biome.json in the project root.
          -- Set require_cwd = false to let Biome format anywhere using its default rules.
          require_cwd = false,
        },
      },

      -- support a global format disable
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end

        local language_lsp_format_opts = {
          c = 'never',
          cpp = 'never',
          liquid = 'never',
          python = 'last',
        }
        return {
          timeout_ms = 2000,
          lsp_format = language_lsp_format_opts[vim.bo[bufnr].filetype] or 'fallback',
        }
      end,
    },
    config = function(_, opts)
      if Snacks then
        Snacks.toggle({
          name = 'auto format buf',
          get = function() return not vim.b.disable_autoformat ~= false end,
          set = function(state)
            if state then
              vim.cmd('FormatEnable!')
            else
              vim.cmd('FormatDisable!')
            end
          end,
        }):map('<leader>vf')
      end

      require('conform').setup(opts)

      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = 'Disable autoformat-on-save',
        bang = true,
      })
      vim.api.nvim_create_user_command('FormatEnable', function(args)
        if args.bang then
          vim.b.disable_autoformat = false
        else
          vim.g.disable_autoformat = false
        end
      end, {
        desc = 'Re-enable autoformat-on-save',
        bang = true,
      })

      if not vim.g.no_mason_autoinstall then
        -- install formatters
        require('mason-conform')
      end
    end,
  },
  {
    'zapling/mason-conform.nvim',
    lazy = true,
    opts = {},
  },
}
