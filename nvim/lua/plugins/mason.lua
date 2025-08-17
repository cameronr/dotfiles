---Borrowed from LazyVim
---@module 'lazy'
---@type LazySpec
return {
  'mason-org/mason.nvim',
  cmd = 'Mason',
  build = ':MasonUpdate',
  opts_extend = { 'ensure_installed' },
  opts = {
    -- it's not actually part of MasonSettings but it's convenient
    ensure_installed = {
      'stylua',
      'shfmt',
      'prettier',
      'prettierd',
      'isort',
    },
  },
  ---@param opts MasonSettings | {ensure_installed: string[]}
  config = function(_, opts)
    require('mason').setup(opts)

    if vim.g.no_mason_autoinstall then return end

    local mr = require('mason-registry')
    mr:on('package:install:success', function()
      vim.defer_fn(function()
        -- trigger FileType event to possibly load this newly installed LSP server
        require('lazy.core.handler.event').trigger({
          event = 'FileType',
          buf = vim.api.nvim_get_current_buf(),
        })
      end, 100)
    end)

    mr.refresh(function()
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          vim.notify('Mason installing ' .. tool)
          p:install()
        end
      end
    end)
  end,
}
