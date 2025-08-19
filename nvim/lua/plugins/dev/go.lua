if vim.fn.executable('go') ~= 1 then return {} end

return {
  {
    'neovim/nvim-lspconfig',
    opts = { servers = { 'gopls' } },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        go = { 'goimports', 'gofumpt' },
      },
    },
  },
}
