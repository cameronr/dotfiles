return {
  {
    'antosha417/nvim-lsp-file-operations',
    lazy = true,
    config = function() require('lsp-file-operations').setup() end,
  },
}
