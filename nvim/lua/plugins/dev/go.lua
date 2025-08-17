if vim.fn.executable('go') ~= 1 then return {} end

return {
  {
    'neovim/nvim-lspconfig',
    opts = { servers = { 'gopls' } },
  },
  {
    'mason-org/mason.nvim',
    opts = { ensure_installed = { 'goimports', 'gofumpt' } },
  },
}
