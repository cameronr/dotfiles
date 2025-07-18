---@module 'lazy'
---@type LazySpec
return {
  -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command in the config to whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000, -- Make sure to load this before all the other start plugins.

  ---@class tokyonight.Config
  opts = {
    style = 'night',
    styles = {
      floats = { 'transparent' },
    },
    lualine_bold = true,

    on_colors = function(c)
      c.border_highlight = c.blue

      -- brighten up the git colors, used for gitsigns (column and lualine)
      c.git.add = c.teal
      c.git.change = c.blue
      c.git.delete = c.red1

      -- Make dark very slightly less dark
      c.bg_dark = '#171821'
      c.bg_statusline = c.bg_dark
    end,

    on_highlights = function(hl, c)
      -- slightly brighter visual selection
      hl.Visual.bg = '#2d3f6f'
      -- Keep visual for popup/picker highlights
      hl.PmenuSel = { bg = hl.Visual.bg }
      hl.TelescopeSelection = { bg = hl.Visual.bg }
      hl.SnacksPickerCursorLine = { bg = hl.Visual.bg }
      hl.SnacksPickerListCursorLine = hl.SnacksPickerCursorLine
      hl.SnacksPickerPreviewCursorLine = hl.SnacksPickerCursorLine

      if vim.o.background == 'dark' then
        -- Use bg.dark from storm (not night) for the cursor line background to make it more subtle
        hl.CursorLine = { bg = '#1f2335' }

        -- Diff colors
        -- Brighten changes within a line
        hl.DiffText = { bg = '#224e38' }
        -- Make changed lines more green instead of blue
        hl.DiffAdd = { bg = '#182f23' }

        -- More saturated DiffDelete
        hl.DiffDelete = { bg = '#4d1919' }

        -- clean up Neogit diff colors (when committing)
        hl.NeogitDiffAddHighlight = { fg = '#82a957', bg = hl.DiffAdd.bg }

        -- Visual selection should match visual mode
        hl.Visual = { bg = '#3f3256' }

        -- Make TS context dimmer and color line numbers
        hl.TreesitterContext = { bg = '#272d45' }
        hl.TreesitterContextLineNumber = { fg = c.fg_gutter, bg = '#272d45' }
      else
        -- Diff colors
        -- Brighten changes within a line
        hl.DiffText = { bg = '#a3dca9' }
        -- Make changed lines more green instead of blue
        hl.DiffAdd = { bg = '#cce5cf' }

        -- clean up Neogit diff colors (when committing)
        hl.NeogitDiffAddHighlight = { fg = '#4d6534', bg = hl.DiffAdd.bg }

        -- Visual selection should match visual mode
        hl.Visual = { bg = '#b69de2' }

        -- Make TS context color line numbers
        hl.TreesitterContextLineNumber = { fg = '#939aba', bg = '#b3b8d1' }

        -- Make yaml properties and strings more distinct
        hl['@property.yaml'] = { fg = '#006a83' }

        -- Make flash label legible in light mode
        if hl.FlashLabel then hl.FlashLabel.fg = c.bg end
      end

      -- telescope
      hl.TelescopeMatching = { fg = hl.IncSearch.bg }

      -- cmp
      hl.CmpItemAbbrMatchFuzzy = { fg = hl.IncSearch.bg }
      hl.CmpItemAbbrMatch = { fg = hl.IncSearch.bg }
      -- Darken cmp menu (src for the completion)
      hl.CmpItemMenu = hl.CmpGhostText

      -- Blink
      hl.Pmenu.bg = c.bg
      hl.PmenuMatch.bg = c.bg
      hl.BlinkCmpLabelMatch = { fg = hl.IncSearch.bg }
      hl.BlinkCmpSource = { fg = c.terminal_black }

      -- FzfLua
      hl.FzfLuaDirPart = hl.NonText
      hl.FzfLuaPathLineNr = { fg = c.fg_dark }
      hl.FzfLuaFzfCursorLine = hl.NonText
      hl.FzfLuaFzfMatch = { fg = hl.IncSearch.bg }
      hl.FzfLuaBufNr = { fg = c.fg }

      -- Snacks
      hl.SnacksPickerBufNr = hl.NonText
      hl.SnacksPickerMatch = { fg = hl.IncSearch.bg }

      -- clean up Neogit diff colors (when committing)
      hl.NeogitDiffContextHighlight = { bg = hl.Normal.bg }
      hl.NeogitDiffContext = { bg = hl.Normal.bg }

      -- More subtle
      hl.IblScope = hl.LineNr
      -- hl.IblScope = { fg = '#283861' }
      hl.IblIndent = { fg = '#1f202e' }
      hl.SnacksIndent = { fg = '#1f202e' }
      hl.SnacksIndentScope = hl.LineNr

      -- Make folds less prominent (especially important for DiffView)
      hl.Folded = { fg = c.blue0, italic = true }

      -- Make diff* transparent for DiffView file panel
      hl.diffAdded = { fg = c.git.add }
      hl.diffRemoved = { fg = c.git.delete }
      hl.diffChanged = { fg = c.git.change }

      -- Make the colors in the Lualine x section dimmer
      local lualine = require('lualine.themes.tokyonight-night')
      lualine.normal.x = { fg = hl.Comment.fg, bg = c.bg_statusline }

      -- Make diagnostic text easier to read (and underlined)
      hl.DiagnosticUnnecessary = hl.DiagnosticUnderlineWarn

      -- Make lsp cursor word highlights dimmer
      hl.LspReferenceWrite = { bg = c.bg_highlight }
      hl.LspReferenceText = { bg = c.bg_highlight }
      hl.LspReferenceRead = { bg = c.bg_highlight }

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

      hl.HighlightUndo = hl.CurSearch
      hl.HighlightRedo = hl.CurSearch

      -- hl.Marks = hl.DiagnosticInfo
      hl.MarkSignHL = hl.DiagnosticInfo
      hl.MarkSignNumHL = hl.LineNR

      -- Less bright trailing space indicator
      hl.MiniTrailspace = { fg = c.red }

      -- Make win separator more prominent
      hl.WinSeparator = { fg = c.bg_highlight }
    end,
  },

  config = function(_, opts)
    require('tokyonight').setup(opts)

    -- Activate the colorscheme here. Tokyonight will pick the right style as set above
    vim.cmd.colorscheme('tokyonight')

    -- restore light/dark background
    local colorscheme_file = vim.fn.stdpath('data') .. '/last-colorscheme'
    local success, colorscheme = pcall(vim.fn.readfile, colorscheme_file)
    if success and vim.tbl_contains(colorscheme, 'tokyonight-day') then vim.o.background = 'light' end

    -- Sync nvim theme to wezterm, mostly to fix cursor color in day mode.
    -- See:
    -- https://github.com/folke/tokyonight.nvim/issues/26
    -- https://github.com/folke/zen-mode.nvim/pull/61
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern = '*',
      callback = function()
        vim.fn.writefile({ vim.g.colors_name }, colorscheme_file)

        local color_scheme = vim.g.colors_name:gsub('-', '_')
        ---@diagnostic disable-next-line: undefined-field
        local stdout = vim.loop.new_tty(1, false)
        if stdout then
          stdout:write(('\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\'):format('FORCE_DAY_MODE', vim.fn.system({ 'base64' }, color_scheme)))
          vim.cmd.redraw()
        end
      end,
    })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
