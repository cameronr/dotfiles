return {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=detailed',
    '--function-arg-placeholders',
    '--fallback-style=llvm',
  },
  ---@param _ vim.lsp.Client
  ---@param bufnr integer
  on_attach = function(client, bufnr)
    local clangd_lspconfig = require('lspconfig.configs.clangd')

    -- Trying to fix error popups with Diffview:// buffers
    -- Still get an initial error popup but at least it's only the one
    local uri = vim.uri_from_bufnr(bufnr)
    if not vim.startswith(uri, 'file://') then
      vim.schedule(function() vim.lsp.buf_detach_client(bufnr, client.id) end)
      return
    end

    -- Register clangd commands manually because we're overriding on_attach
    for name, def in pairs(clangd_lspconfig.commands) do
      vim.api.nvim_buf_create_user_command(bufnr, name, def[1], { desc = def.description })
    end

    vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', { buffer = bufnr, desc = 'Switch Source/Header (C/C++)' })
  end,
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
