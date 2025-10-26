return {
  settings = {
    emmylua = {
      runtime = {
        version = 'LuaJIT', -- the version nvim uses
      },

      workspace = {
        library = {
          '$VIMRUNTIME', -- for vim.*
        },
        ignoreGlobs = {
          '**/*_spec.lua', -- to avoid some weird type defs in a plugin
        },
      },

      -- workspace = {
      --   -- Include Neovim's runtime files for API awareness
      --   library = {
      --     vim.env.VIMRUNTIME .. '/lua',
      --     vim.env.VIMRUNTIME .. '/lua/vim',
      --     vim.env.VIMRUNTIME .. '/lua/vim/lsp',
      --   },
      --   -- If your plugin depends on other Lua paths:
      --   -- checkThirdParty = false,
      -- },
      diagnostics = {
        enable = true,
        globals = {
          'vim',
          'Snacks',
          'it',
          'describe',
          'before_each',
          'after_each',
        },
        disable = { 'unnecessary-if' },
      },

      -- Hints
      hint = {
        metaCallHint = false,
        -- paramHint = true,
        -- "paramHint": true,
        -- "indexHint": true,
        -- "localHint": true,
        -- "overrideHint": true,
        -- "metaCallHint": true
        -- setType = false, -- show type hints for assignments
        -- paramType = true, -- show parameter types
        -- paramName = 'Disable', -- show parameter names
        -- semicolon = 'Disable',
        -- arrayIndex = 'Disable',
      },
    },
  },
}
