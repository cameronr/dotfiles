return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000, -- Make sure to load this before all the other start plugins.
    opts = {
      style = 'night',
      styles = {
        comments = { italic = false },
      },
      lualine_bold = true,
      on_highlights = function(hl, _)
        -- Use bg.dark for the cursor line background to make it more subtle
        hl.CursorLine = { bg = '#1f2335' }

        -- Make folds less prominent (especially important for DiffView)
        hl.Folded = { fg = 'none' }

        -- Make IndentBlankLines indent markers much fainter (bg_dark in tokyonight)
        hl.IblIndent = { fg = '#1f2335' }

        -- Brighter git colors in LuaLine
        hl.LuaLineDiffAdd = { fg = '#2e9e98' }
        hl.LuaLineDiffChange = { fg = '#7aa2f7' }
        hl.LuaLineDiffDelete = { fg = '#f25a64' }

        hl.DiagnosticUnnecessary = hl.DiagnosticUnderlineWarn
      end,
    },

    init = function()
      -- Activate the colorscheme here. Tokyonight will pick the right style as set above
      vim.cmd.colorscheme 'tokyonight'

      -- You can configure highlights by doing something like:
      -- Setting italic to false in styles.comments above accomplishes the same thing
      -- vim.cmd.hi 'Comment gui=none'

      -- Could use the below to make both Lualine and Gitsigns brighter
      -- vim.cmd.hi 'GitSignsAdd guifg=#2e9e98'
      -- vim.cmd.hi 'GitSignsChange guifg=#7aa2f7'
      -- vim.cmd.hi 'GitSignsDelete guifg=#f25a64'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
