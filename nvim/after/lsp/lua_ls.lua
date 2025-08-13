return {
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

        -- only need these for diffview as lazydev doesn't seem to cover them?
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
}
