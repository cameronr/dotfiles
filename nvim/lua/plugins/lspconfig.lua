if vim.fn.has('nvim-0.11') == 0 then return {} end

-- LSP Plugins
return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',

    ---@module 'lazydev'
    ---@type lazydev.Config
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },

  ---@module 'lazy'
  ---@type LazySpec
  {
    'Bilal2453/luvit-meta',
    lazy = true,
  },

  ---@module 'lazy'
  ---@type LazySpec
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile', 'InsertEnter' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'mason-org/mason.nvim', opts = {} },
      -- we'll manually call mason-lspconfig's config function
      { 'mason-org/mason-lspconfig.nvim', config = function() end },

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },
    },
    opts_extend = { 'servers' },
    opts = {
      servers = {
        'lua_ls',
        'bashls',
        'html',
        'cssls',
        'tailwindcss',
        'eslint',
        'basedpyright',
        'ruff',
        'taplo',
        'typos_lsp',
        'yamlls',
        'marksman',
        'copilot',
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>cR', vim.lsp.buf.rename, 'Code: rename')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, 'Rename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', function() require('tiny-code-action').code_action({}) end, 'Code action', { 'n', 'x' })
          map('<leader>cA', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })

          map('<leader>cI', '<cmd>LspInfo<CR>', 'Inspect LSs')

          map('<leader>vR', '<cmd>LspRestart<CR>', 'Restart LSP')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, 'Declaration')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', function() vim.lsp.buf.hover({ border = 'rounded', focusable = false }) end, 'Hover Documentation')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- Enable inlay hints by default
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then vim.lsp.inlay_hint.enable() end

          -- Enable on type formatting if it exists
          -- https://www.reddit.com/r/neovim/comments/1n59kir/neovim_now_supports_lsp_ontype_formatting/
          if vim.lsp.on_type_formatting then
            -- TODO: add snacks toggle for this
            vim.notify('enabling on type formatting')
            vim.lsp.on_type_formatting.enable(true, { client_id = event.data.client_id })
          end
        end,
      })

      local diagnostic_icons = require('settings').icons.diagnostics
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = false,
        float = { border = 'rounded', source = 'if_many' },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = diagnostic_icons.Error,
            [vim.diagnostic.severity.WARN] = diagnostic_icons.Warn,
            [vim.diagnostic.severity.INFO] = diagnostic_icons.Info,
            [vim.diagnostic.severity.HINT] = diagnostic_icons.Hint,
          },
        },
      })

      local mlspc_opts = {}
      if not vim.g.no_mason_autoinstall then mlspc_opts.ensure_installed = opts.servers end

      if vim.tbl_contains(opts.servers, 'lua_ls') and vim.tbl_contains(opts.servers, 'emmylua_ls') then
        mlspc_opts.automatic_enable = {
          exclude = {
            'lua_ls',
          },
        }
      end

      -- automatically enable servers and install (unless autoinstall disabled)
      require('mason-lspconfig').setup(mlspc_opts)

      if vim.fn.has('nvim-0.12') == 1 then vim.lsp.inline_completion.enable() end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
