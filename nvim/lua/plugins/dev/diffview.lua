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
    view = {
      default = {
        disable_diagnostics = true,
      },
      merge_tool = {
        layout = 'diff3_mixed',
      },
    },
    enhanced_diff_hl = true,
    hooks = {
      diff_buf_win_enter = function(bufnr, winid, _)
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

        -- HACK: turn off inlay hints, but diffview is triggering the lsp
        -- to renable them even if they were off (re-editing the buffer?)
        -- add a 100ms delay to make sure they're off. gross.
        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            local buf = vim.api.nvim_win_get_buf(win)
            vim.lsp.inlay_hint.enable(false, { bufnr = buf })
          end
        end, 100)
      end,
    },
  },
}
