if vim.g.treesitter_branch ~= 'main' then return {} end

-- on main branch, treesitter isn't started automatically
vim.api.nvim_create_autocmd({ 'Filetype' }, {
  callback = function(event)
    local ignored_fts = {
      'snacks_dashboard',
      'prompt', -- bt: snacks_picker_input
    }

    if vim.bo[event.buf].bt == 'nofile' then return end
    if vim.tbl_contains(ignored_fts, event.match) then return end

    local ok, result = pcall(vim.treesitter.start, event.buf)
    if not ok then
      local ft = vim.bo[event.buf].ft
      local lang = vim.treesitter.language.get_lang(ft)
      if lang then
        if not require('nvim-treesitter').install({ lang }) then
          vim.notify(result .. '\nbt: ' .. vim.bo[event.buf].bt)
          return
        end
      end

      ok, result = pcall(vim.treesitter.start, event.buf)
      if not ok then return end
    end

    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end,
})

return {
  ---@module 'lazy'
  ---@type LazySpec
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = 'VeryLazy',
    dependencies = {
      { 'folke/ts-comments.nvim', opts = {} },
    },

    branch = 'main',
    build = ':TSUpdate',

    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    ---@module 'nvim-treesitter'
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {},

    config = function(_, opts)
      local ensure_installed = {
        'bash',
        'c',
        'css',
        'diff',
        'gitcommit',
        'html',
        'javascript',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      }

      require('nvim-treesitter').install(ensure_installed)
    end,
  },

  ---@module 'lazy'
  ---@type LazySpec
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',

    branch = 'main',

    keys = {
      {
        '[f',
        function() require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects') end,
        desc = 'prev function',
        mode = { 'n', 'x', 'o' },
      },
      {
        ']f',
        function() require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects') end,
        desc = 'next function',
        mode = { 'n', 'x', 'o' },
      },
      {
        '[F',
        function() require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects') end,
        desc = 'prev function end',
        mode = { 'n', 'x', 'o' },
      },
      {
        ']F',
        function() require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects') end,
        desc = 'next function end',
        mode = { 'n', 'x', 'o' },
      },
      {
        '[a',
        function() require('nvim-treesitter-textobjects.move').goto_previous_start('@parameter.outer', 'textobjects') end,
        desc = 'prev argument',
        mode = { 'n', 'x', 'o' },
      },
      {
        ']a',
        function() require('nvim-treesitter-textobjects.move').goto_next_start('@parameter.outer', 'textobjects') end,
        desc = 'next argument',
        mode = { 'n', 'x', 'o' },
      },
      {
        '[A',
        function() require('nvim-treesitter-textobjects.move').goto_previous_end('@parameter.outer', 'textobjects') end,
        desc = 'prev argument end',
        mode = { 'n', 'x', 'o' },
      },
      {
        ']A',
        function() require('nvim-treesitter-textobjects.move').goto_next_end('@parameter.outer', 'textobjects') end,
        desc = 'next argument end',
        mode = { 'n', 'x', 'o' },
      },
      {
        '[s',
        function() require('nvim-treesitter-textobjects.move').goto_previous_start('@block.outer', 'textobjects') end,
        desc = 'prev block',
        mode = { 'n', 'x', 'o' },
      },
      {
        ']s',
        function() require('nvim-treesitter-textobjects.move').goto_next_start('@block.outer', 'textobjects') end,
        desc = 'next block',
        mode = { 'n', 'x', 'o' },
      },
      {
        '[S',
        function() require('nvim-treesitter-textobjects.move').goto_previous_end('@block.outer', 'textobjects') end,
        desc = 'prev block',
        mode = { 'n', 'x', 'o' },
      },
      {
        ']S',
        function() require('nvim-treesitter-textobjects.move').goto_next_end('@block.outer', 'textobjects') end,
        desc = 'next block',
        mode = { 'n', 'x', 'o' },
      },
      {
        'gan',
        function() require('nvim-treesitter-textobjects.swap').swap_next('@parameter.inner') end,
        desc = 'swap next argument',
      },
      {
        'gap',
        function() require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner') end,
        desc = 'swap prev argument',
      },
    },

    opts = {
      move = {
        enable = true,
        set_jumps = true,
      },
      swap = {
        enable = true,
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
