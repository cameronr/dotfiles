if vim.fn.executable('rustc') ~= 1 then return {} end

return {
  {
    'neovim/nvim-lspconfig',
    opts = { servers = { 'rust_analyzer' } },
  },
}
