return {
  ---@module 'lazy'
  ---@type LazySpec
  { -- Autocompletion
    -- 'hrsh7th/nvim-cmp',
    'iguanacucumber/magazine.nvim',
    enabled = vim.g.cmp_engine == 'cmp',

    name = 'nvim-cmp',

    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            'rafamadriz/friendly-snippets',
            config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      -- 'hrsh7th/cmp-path', -- suggestions from path
      -- 'hrsh7th/cmp-buffer', -- suggestions from current buffer
      -- 'hrsh7th/cmp-cmdline', -- suggestions from commands

      { 'iguanacucumber/mag-nvim-lsp', name = 'cmp-nvim-lsp', opts = {} },
      { 'iguanacucumber/mag-nvim-lua', name = 'cmp-nvim-lua' },
      { 'iguanacucumber/mag-buffer', name = 'cmp-buffer' },
      { 'iguanacucumber/mag-cmdline', name = 'cmp-cmdline' },

      'https://codeberg.org/FelipeLema/cmp-async-path', -- not by me, but better than cmp-path

      { 'petertriho/cmp-git', opts = {} }, -- suggestions for git
      -- 'dmitmel/cmp-cmdline-history', -- suggestions from command history
    },
    config = function()
      -- See `:help cmp`
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')
      luasnip.config.setup({})

      -- cmp.mapping.confirm introduces a delay since it doesn't check
      -- if cmp is visible first. this is particularly annoying with <CR>
      -- as a confirm key
      local faster_confirm = function(opts)
        return function(fallback)
          if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
            if cmp.confirm(opts) then return end
          end
          fallback()
        end
      end

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        completion = { completeopt = 'menu,menuone,noinsert,noselect,popup' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = faster_confirm({ select = true }),

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          ['<CR>'] = faster_confirm({ select = false }),

          -- Select next/previous item with Tab / Shift + Tab
          -- Lets you tab through snippets
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Don't use up/down for the selection window
          ['<Down>'] = cmp.mapping(function(fallback)
            cmp.close()
            fallback()
          end, { 'i' }),
          ['<Up>'] = cmp.mapping(function(fallback)
            cmp.close()
            fallback()
          end, { 'i' }),

          ['<C-e>'] = cmp.mapping.close(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          -- ['<C-Space>'] = cmp.mapping.complete({}),

          -- Close popup with ctrl-space. Don't toggle because it breaks telescope refine
          ['<C-Space>'] = cmp.mapping(function(fallback)
            if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
              cmp.close()
              return
            end
            fallback()
          end),

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        }),
        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            vim_item.kind = lspkind.symbolic(vim_item.kind, {
              mode = 'symbol',
              symbol_map = { Supermaven = '󰰣' },
            }) .. ' '
            local maxwidth = 50
            local ellipsis_char = '…'
            if vim.fn.strchars(vim_item.abbr) > maxwidth then vim_item.abbr = vim.fn.strcharpart(vim_item.abbr, 0, maxwidth) .. ellipsis_char end
            vim_item.menu = ({
              nvim_lsp = 'LSP',
              luasnip = 'Snip',
              buffer = 'Buf',
              path = 'Path',
              async_path = 'Path',
            })[entry.source.name]
            return vim_item
          end,
        },

        -- view = {
        --   ---@diagnostic disable-next-line: missing-fields
        --   entries = {
        --     follow_cursor = true,
        --   },
        -- },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp', max_item_count = 20 },
          { name = 'luasnip' },
          { name = 'buffer', max_item_count = 20 },
          { name = 'async_path' },
          { name = 'supermaven' },
          { name = 'git' },
        },
        -- experimental = {
        --   ghost_text = true,
        -- },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      -- / completion from buffer
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer', max_item_count = 20 },
          -- { name = 'cmdline_history' },
        },
      })

      -- Enable command-line completion for :

      -- https://github.com/hrsh7th/nvim-cmp/issues/181
      -- local has_words_before = function()
      --   local cursor = vim.api.nvim_win_get_cursor(0)
      --   return (vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], true)[1] or ''):sub(cursor[2], cursor[2]):match '%s'
      -- end

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline({
          ['<C-Space>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.abort()
            else
              fallback()
            end
          end, { 'c' }),

          -- For CR, if cmp is open and an option is selected, confirm it but don't
          -- submit the command (so the user can type arguments if needed)
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() ~= nil then
              cmp.confirm()
            else
              cmp.close()
              fallback()
            end
          end, { 'c' }),
          -- ['<Down>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_next_item()
          --     -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
          --     -- that way you will only jump inside the snippet region
          --   elseif luasnip.expand_or_jumpable() then
          --     luasnip.expand_or_jump()
          --   elseif has_words_before() then
          --     cmp.complete()
          --   else
          --     fallback()
          --   end
          -- end, { 'c' }),
          -- ['<Up>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   elseif luasnip.jumpable(-1) then
          --     luasnip.jump(-1)
          --   else
          --     fallback()
          --   end
          -- end, { 'c' }),
        }),
        sources = {
          { name = 'cmdline', max_item_count = 20 },
          -- { name = 'cmdline_history', max_item_count = 5 },
        },
        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          fields = { 'abbr' },
        },
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
