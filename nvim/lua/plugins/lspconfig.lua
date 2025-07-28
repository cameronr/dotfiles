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
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim' },
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      -- 'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
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

          if vim.g.picker_engine == 'telescope' then
            -- Find references for the word under your cursor.
            map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

            -- Jump to the implementation of the word under your cursor.
            --  Useful when your language has ways of declaring types without an actual implementation.
            map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map('<leader>ss', function() require('telescope.builtin').lsp_document_symbols() end, 'Document symbols')

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map('<leader>sS', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, 'Workspace symbols')
          elseif vim.g.picker_engine == 'fzf' then
            map('grd', '<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>', 'Goto definition')
            map('grr', '<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>', 'References')
            map('gri', '<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>', 'Goto implementation')
            map('grt', '<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>', 'Goto type definition')
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
          map('K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Hover Documentation')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- Enable inlay hints by default
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then vim.lsp.inlay_hint.enable() end
        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = false,
        float = { border = 'rounded', source = 'if_many' },
      })

      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN] = ' ',
            [vim.diagnostic.severity.INFO] = ' ',
            [vim.diagnostic.severity.HINT] = '',
          },
        },
      })

      local servers = {
        'lua_ls',
        'bashls',
        'html',
        'cssls',
        'tailwindcss',
        'eslint',
        'pyright',
        'ruff',
        'taplo',
        'typos_lsp',
        'yamlls',
      }

      local extra_tools = {
        'stylua',
        'prettier',
        'prettierd',
        'isort',
        'beautysh',
      }

      if vim.fn.executable('rustc') == 1 then table.insert(servers, 'rust_analyzer') end
      if vim.fn.executable('go') == 1 then
        table.insert(servers, 'gopls')
        extra_tools = vim.list_extend(extra_tools, { 'goimports', 'gofumpt' })
      end

      local ensure_installed = vim.list_extend(servers, extra_tools)

      if not vim.g.no_mason_autoinstall then
        local mti = require('mason-tool-installer')
        -- we lazy load so we trigger loading manually
        mti.setup({ ensure_installed = ensure_installed, run_on_start = false })
        mti.check_install()
      end

      ---@type MasonLspconfigSettings
      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup({
        automatic_enable = vim.tbl_keys(servers or {}),
      })
      vim.lsp.enable(servers)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
