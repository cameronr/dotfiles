return {
  check = {
    command = 'clippy',
    extraArgs = { '--no-deps' },
  },
  inlayHints = {
    bindingModeHints = { enable = true },
    closingBraceHints = { minLines = 0 },
    closureCaptureHints = { enable = true },
    closureReturnTypeHints = { enable = 'always' },
    expressionAdjustmentHints = {
      enable = 'reborrow',
      hideOutsideUnsafe = true,
    },
    lifetimeElisionHints = {
      enable = 'skip_trivial',
      useParameterNames = true,
    },
    maxLength = vim.NIL,
    typing = { triggerChars = '=.{(><' },
  },
  cargo = {
    allFeatures = true,
    loadOutDirsFromCheck = true,
    buildScripts = {
      enable = true,
    },
  },
}
