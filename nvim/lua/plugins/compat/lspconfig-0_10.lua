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
      { 'mason-org/mason.nvim', version = 'v1.*', opts = {} },
      { 'mason-org/mason-lspconfig.nvim', version = 'v1.*' },
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

          if not vim.g.picker_engine == 'telescope' then
            -- Jump to the definition of the word under your cursor.
            --  This is where a variable was first declared, or where a function is defined, etc.
            --  To jump back, press <C-t>.
            map('gd', function() require('telescope.builtin').lsp_definitions() end, 'Goto definition')

            -- Find references for the word under your cursor.
            map('gr', function() require('telescope.builtin').lsp_references() end, 'Goto references')

            -- Jump to the implementation of the word under your cursor.
            --  Useful when your language has ways of declaring types without an actual implementation.
            map('gI', function() require('telescope.builtin').lsp_implementations() end, 'Goto implementation')

            -- Jump to the type of the word under your cursor.
            --  Useful when you're not sure what type a variable is and you want to see
            --  the definition of its *type*, not where it was *defined*.
            map('<leader>cD', function() require('telescope.builtin').lsp_type_definitions() end, 'Code Type definition')

            -- Fuzzy find all the symbols in your current document.
            --  Symbols are things like variables, functions, types, etc.
            map('<leader>ss', function() require('telescope.builtin').lsp_document_symbols() end, 'Document symbols')

            -- Fuzzy find all the symbols in your current workspace.
            --  Similar to document symbols, except searches over your entire project.
            map('<leader>sS', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, 'Workspace symbols')
          elseif vim.g.picker_engine == 'fzf' then
            map('gd', '<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>', 'Goto definition')
            map('gr', '<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>', 'References')
            map('gI', '<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>', 'Goto implementation')
            map('gy', '<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>', 'Goto type definition')
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>cR', vim.lsp.buf.rename, 'Code: rename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          -- map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
          -- map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
          map('<leader>ca', function() require('tiny-code-action').code_action({}) end, 'Code action', { 'n', 'x' })
          map('<leader>cA', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })

          map('<leader>vR', '<cmd>LspRestart<CR>', 'Restart LSP')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, 'Goto declaration')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr) return client:supports_method(method, bufnr) end

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Enable inlay hints by default
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            --
            vim.lsp.inlay_hint.enable()
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      if vim.g.cmp_engine == 'cmp' then
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      else
        -- blink does this automatically in nvim >= 0.11, but i think that code requires us to update to
        -- newer lsp setup style
        -- https://github.com/Saghen/blink.cmp/blob/102db2f5996a46818661845cf283484870b60450/plugin/blink-cmp.lua
        capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities(capabilities))
      end

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts

      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = false,
        float = { border = 'rounded', source = 'if_many' },
      })

      if vim.fn.has('nvim-0.10') == 1 then
        -- user newer mechanism if possible, fixes signs in neotree
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
      else
        -- local signs = { Error = '󰅚 ', Warn = '󰀪 ', Info = ' ', Hint = '󰌶 ' }
        local signs = { Error = ' ', Warn = ' ', Info = ' ', Hint = '' }

        for type, icon in pairs(signs) do
          local hl = 'DiagnosticSign' .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
        end
      end

      -- Add border to LSP window. 0.11 >= uses vim.o.winborder
      if vim.fn.has('nvim-0.11') == 0 then
        ---@diagnostic disable-next-line: deprecated
        vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = 'rounded',
        })
      end

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = {},
        --

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = 'Replace',
              },
              codeLens = {
                enable = true,
              },
              doc = {
                privateName = { '^_' },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = 'Disable',
                semicolon = 'Disable',
                arrayIndex = 'Disable',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {
                  'vim',
                  'Snacks',
                  'it',
                  'describe',
                  'before_each',
                  'after_each',
                },
              },
            },
          },
        },

        -- Bash
        bashls = {
          filetypes = { 'sh', 'bash' },
        },

        -- HTML / CSS
        html = {},
        cssls = {},
        -- tailwindcss = {},

        -- Javascript/Typescript
        -- ts_ls = {},

        -- Python
        pyright = {},
        ruff = {},

        -- Ruby for Shopify
        -- ruby_lsp = {
        --   init_options = {
        --     formatter = 'standard',
        --     linters = { 'standard' },
        --   },
        -- },

        rust_analyzer = {
          cargo = {
            allFeatures = true,
            loadOutDirsFromCheck = true,
            buildScripts = {
              enable = true,
            },
          },
          -- Add clippy lints for Rust.
          checkOnSave = true,
          procMacro = {
            enable = true,
            ignored = {
              ['async-trait'] = { 'async_trait' },
              ['napi-derive'] = { 'napi' },
              ['async-recursion'] = { 'async_recursion' },
            },
          },
        },

        -- TOML
        taplo = {},

        -- Shopify
        -- theme_check = {},

        -- Typo is too noisy for me without a simple way to override
        typos_lsp = {
          on_attach = function(client, bufnr)
            -- detach from non-modifiable buffers
            if not vim.bo[bufnr].modifiable then vim.lsp.buf_detach_client(bufnr, client.id) end
          end,
        },

        -- YAML
        yamlls = {
          settings = {
            yaml = {
              schemastore = { enable = true },
              customTags = {
                '!secret scalar',
                '!include scalar',
                '!include_dir_merge_named scalar',
                '!include_dir_merge_list scalar',
                '!input scalar',
              },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.

      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code

        -- https://github.com/mfussenegger/nvim-lint/issues/462#issuecomment-2291862784
        { 'eslint_d', version = '13.1.2' },
      })

      if not vim.g.no_mason_autoinstall then require('mason-tool-installer').setup({ ensure_installed = ensure_installed }) end

      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup({
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })

      -- Install Conform formatters
      if not vim.g.no_mason_autoinstall then require('mason-conform').setup({}) end

      -- Border for LSPInfo
      require('lspconfig.ui.windows').default_options.border = 'single'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
