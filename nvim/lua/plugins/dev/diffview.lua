---@module 'lazy'
---@type LazySpec
return {
  'sindrets/diffview.nvim',
  -- lazy = true,
  keys = {
    { '<leader>hd', '<cmd>DiffviewOpen -uno<CR>', desc = 'git diff against index' },
  },
  cmd = 'DiffviewOpen',
  opts = {
    enhanced_diff_hl = true,
    hooks = {
      diff_buf_win_enter = function(bufnr, winid, ctx)
        -- Turn off cursor line for diffview windows because of BG conflict
        -- setting gross underline:
        -- https://github.com/neovim/neovim/issues/9800
        vim.wo[winid].culopt = 'number'

        -- clear the lsp autocmd that highlights the word under the cursor
        pcall(vim.api.nvim_clear_autocmds, {
          group = 'kickstart-lsp-highlight',
          buffer = bufnr,
        })

        -- turn off gitsigns inline diff
        ---@diagnostic disable-next-line: param-type-mismatch
        pcall(vim.cmd, 'Gitsigns toggle_linehl false')
        ---@diagnostic disable-next-line: param-type-mismatch
        pcall(vim.cmd, 'Gitsigns toggle_word_diff false')

        -- clear highlights
        vim.cmd('nohl')

        -- set wrap
        vim.wo[winid].wrap = true
      end,
    },
  },
}
