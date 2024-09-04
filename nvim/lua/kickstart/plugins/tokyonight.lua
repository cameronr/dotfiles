return {
  -- You can easily change to a different colorscheme.
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
      floats = { 'transparent' },
    },
    lualine_bold = true,
    on_colors = function(c) c.border_highlight = c.blue end,
    on_highlights = function(hl, c)
      -- This is bg_dark from the default tokyonight theme (not tokyonight night)
      local lighterBg = '#1f2335'

      if vim.o.background ~= 'light' then
        -- Use bg.dark for the cursor line background to make it more subtle
        hl.CursorLine = { bg = lighterBg }

        -- Make the search / completion highlights stand out more
        hl.TelescopeMatching = { bg = '#185c81' }
        hl.CmpItemAbbrMatchFuzzy = { bg = '#185c81' }
        hl.CmpItemAbbrMatch = { bg = '#185c81' }
      else
        hl.TelescopeMatching = { bg = '#93cceb' }
        hl.CmpItemAbbrMatchFuzzy = { bg = '#93cceb' }
        hl.CmpItemAbbrMatch = { bg = '#93cceb' }
      end

      hl.IblScope = { fg = '#43709B' }

      -- Make folds less prominent (especially important for DiffView)
      hl.Folded = { fg = 'none' }

      -- Brighter git colors in LuaLine
      hl.LuaLineDiffAdd = { fg = '#2e9e98' }
      hl.LuaLineDiffChange = { fg = c.blue }
      -- hl.LuaLineDiffDelete = { fg = c.dark5 }

      -- Make diagnostic text easier to read (and underlined)
      hl.DiagnosticUnnecessary = hl.DiagnosticUnderlineWarn

      hl.TelescopePromptTitle = {
        fg = c.fg,
      }
      hl.TelescopePromptBorder = {
        fg = c.blue1,
      }
      hl.TelescopeResultsTitle = {
        fg = c.purple,
      }
      hl.TelescopePreviewTitle = {
        fg = c.orange,
      }
    end,
  },

  init = function()
    -- Activate the colorscheme here. Tokyonight will pick the right style as set above
    vim.cmd.colorscheme('tokyonight')

    -- You can configure highlights by doing something like:
    -- Setting italic to false in styles.comments above accomplishes the same thing
    -- vim.cmd.hi 'Comment gui=none'

    -- Could use the below to make both Lualine and Gitsigns brighter
    -- vim.cmd.hi 'GitSignsChange guifg=#7aa2f7'
    -- vim.cmd.hi 'GitSignsDelete guifg=#f25a64'
  end,
}
-- vim: ts=2 sts=2 sw=2 et
