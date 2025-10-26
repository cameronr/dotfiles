return {
  settings = {
    emmylua = {
      runtime = {
        version = 'LuaJIT', -- the version nvim uses
      },

      workspace = {
        library = {
          '$VIMRUNTIME', -- for vim.*
          '$HOME/.local/share/nvim/lazy/luvit-meta/library',
        },
        ignoreGlobs = {
          '**/*_spec.lua', -- to avoid some weird type defs in a plugin
        },
      },

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
