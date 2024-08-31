return {
  {
    'antosha417/nvim-lsp-file-operations',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neo-tree/neo-tree.nvim',
    },
    config = function() require('lsp-file-operations').setup() end,
  },
}
