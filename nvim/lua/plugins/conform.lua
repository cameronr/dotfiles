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
        function() require('conform').format({ async = true, lsp_format = 'fallback' }) end,
        mode = '',
        desc = 'Format buffer',
      },
    },
    config = function()
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

      ---@module 'conform'
      ---@type conform.setupOpts
      require('conform').setup({
        notify_on_error = true,
        -- log_level = vim.log.levels.INFO,
        formatters_by_ft = {
          lua = { 'stylua' },

          c = { 'uncrustify' },
          cpp = { 'uncrustify' },
          go = { 'goimports', 'gofumpt' },
          python = { 'isort' },

          -- webdev
          javascript = { 'prettierd', 'prettier', stop_after_first = true },
          typescript = { 'prettierd', 'prettier', stop_after_first = true },
          javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
          svelte = { 'prettierd', 'prettier', stop_after_first = true },
          css = { 'prettierd', 'prettier', stop_after_first = true },
          html = { 'prettierd', 'prettier', stop_after_first = true },
          json = { 'prettierd', 'prettier', stop_after_first = true },
          graphql = { 'prettierd', 'prettier', stop_after_first = true },
          liquid = { 'prettierd', 'prettier', stop_after_first = true },

          -- text
          yaml = { 'prettierd', 'prettier', stop_after_first = true },
          markdown = { 'prettierd' },

          -- shell
          sh = { 'beautysh' },
          zsh = { 'beautysh' },
        },

        -- support a global format disable
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end

          -- Language specific configuration of lsp fallback
          --
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          --
          -- For python, we want to fallback to the rust lsp formatter (not stop at isort)
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
      })

      -- From: https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#command-to-toggle-format-on-save
      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
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
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
