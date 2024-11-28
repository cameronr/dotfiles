return {
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

      require('conform').setup({
        notify_on_error = true,
        -- log_level = vim.log.levels.INFO,
        -- Conform for formatters
        formatters = {
          yamlfix = {
            env = {
              YAMLFIX_SEQUENCE_STYLE = 'block_style',
              YAMLFIX_preserve_quotes = 'true',
            },
          },
          eslint_d = {
            require_cwd = true,
          },
        },
        --
        formatters_by_ft = {
          lua = { 'stylua' },
          -- Conform can also run multiple formatters sequentially
          python = { 'isort', 'black' },
          --
          -- You can use a sub-list to tell conform to run *until* a formatter
          -- is found.
          javascript = { 'eslint_d', 'prettierd', 'prettier', stop_after_first = true },
          typescript = { 'eslint_d', 'prettierd', 'prettier', stop_after_first = true },
          javascriptreact = { 'eslint_d', 'prettierd', 'prettier', stop_after_first = true },
          typescriptreact = { 'eslint_d', 'prettierd', 'prettier', stop_after_first = true },
          svelte = { 'prettierd', 'prettier', stop_after_first = true },
          css = { 'prettierd', 'prettier', stop_after_first = true },
          html = { 'prettierd', 'prettier', stop_after_first = true },
          json = { 'prettierd', 'prettier', stop_after_first = true },
          yaml = { 'prettierd', 'prettier', stop_after_first = true },
          markdown = { 'prettierd', 'prettier', stop_after_first = true },
          graphql = { 'prettierd', 'prettier', stop_after_first = true },
          liquid = { 'prettierd', 'prettier', stop_after_first = true },
          c = { 'uncrustify' },
          cpp = { 'uncrustify' },

          sh = { 'beautysh' },
          zsh = { 'beautysh' },
          -- yaml = { 'yamlfix' },
        },

        -- support a global format disable
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = {
            c = true,
            cpp = true,
            liquid = true,
          }
          local lsp_format_opt
          if disable_filetypes[vim.bo[bufnr].filetype] then
            lsp_format_opt = 'never'
          else
            lsp_format_opt = 'fallback'
          end
          return {
            timeout_ms = 2000,
            lsp_format = lsp_format_opt,
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
