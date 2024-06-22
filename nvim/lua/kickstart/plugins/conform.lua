return {
  -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    {
      'zapling/mason-conform.nvim',
      -- setup is conditionally called in lspconfig.lua so don't set any opts = {} here
    },
  },
  keys = {
    {
      '<leader>f',
      function() require('conform').format { async = true, lsp_fallback = true } end,
      mode = '',
      desc = 'Format buffer',
    },
  },
  config = function()
    require('conform').setup {
      notify_on_error = true,
      -- Conform for formatters
      formatters = {
        yamlfix = {
          env = {
            YAMLFIX_SEQUENCE_STYLE = 'block_style',
            YAMLFIX_preserve_quotes = 'true',
          },
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
        javascript = { { 'prettierd', 'prettier' } },
        typescript = { { 'prettierd', 'prettier' } },
        javascriptreact = { { 'prettierd', 'prettier' } },
        typescriptreact = { { 'prettierd', 'prettier' } },
        svelte = { { 'prettierd', 'prettier' } },
        css = { { 'prettierd', 'prettier' } },
        html = { { 'prettierd', 'prettier' } },
        json = { { 'prettierd', 'prettier' } },
        yaml = { { 'prettierd', 'prettier' } },
        markdown = { { 'prettierd', 'prettier' } },
        graphql = { { 'prettierd', 'prettier' } },
        liquid = { { 'prettierd', 'prettier' } },

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
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
    }

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
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Re-enable autoformat-on-save',
    })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
