---@module 'lazy'
---@type LazySpec
return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000, -- Make sure to load this before all the other start plugins.

  ---@class tokyonight.Config
  opts = {
    style = 'night',
    styles = {
      floats = { 'transparent' },
    },
    plugins = {
      rainbow = true, -- for blink.pairs
    },
    lualine_bold = true,

    on_colors = function(c)
      c.border_highlight = c.blue

      -- brighten up the git colors, used for gitsigns (column and lualine)
      c.git.add = c.teal
      c.git.change = c.blue
      c.git.delete = c.red1

      if vim.o.background == 'dark' then
        -- Brighten changes within a line
        c.diff.text = '#204b23'
        -- Make changed lines more green instead of blue
        c.diff.add = '#182f23'
        -- Make deletes more saturated
        c.diff.delete = '#4d1919'

        -- If night style, make bg_dark very slightly less dark
        c.bg_dark = '#171821'
        c.bg_statusline = c.bg_dark
      end

      -- c.orange = '#d77f4a' --#f4975f '#ff9e64' #ff966c #d77f4a
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

        -- Visual selection should match visual mode color, but more saturated
        hl.Visual = { bg = '#2d213d' }

        -- Make TS context dimmer and color line numbers
        hl.TreesitterContext = { bg = '#272d45' }
        hl.TreesitterContextLineNumber = { fg = c.fg_gutter, bg = '#272d45' }

        -- Make the colors in the Lualine x section dimmer
        local lualine = require('lualine.themes.tokyonight-night')
        lualine.normal.x = { fg = hl.Comment.fg, bg = c.bg_statusline }

        -- modes: I want a more muted green for the insert line
        -- #1a2326 slightly less green
        -- #1f2a2e a little brighter
        -- #1d272a one notch less bright
        hl.ModesInsertCursorLine = { bg = '#1f2a2e' }

        -- Don't want teal in neogit diff add
        hl.NeogitDiffAddHighlight = { fg = '#abd282', bg = hl.DiffAdd.bg }

        -- More subtle snacks indent colors
        hl.SnacksIndent = { fg = '#1f202e' }
        hl.SnacksIndentScope = hl.LineNr

        -- brighter blue for search, washes out txt less
        hl.Search.bg = '#2c52b3'

        -- Less nuclear flash
        hl.FlashLabel.bg = '#c2357a'
      else
        -- Visual selection should match visual mode
        hl.Visual = { bg = '#d6cae1' }

        -- Make TS context color line numbers
        hl.TreesitterContextLineNumber = { fg = '#939aba', bg = '#b3b8d1' }

        -- Diff colors
        -- Brighten changes within a line
        hl.DiffText = { bg = '#a3dca9' }
        -- Make changed lines more green instead of blue
        hl.DiffAdd = { bg = '#cce5cf' }

        -- clean up Neogit diff colors (when committing)
        hl.NeogitDiffAddHighlight = { fg = '#4d6534', bg = hl.DiffAdd.bg }

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

      -- clean up gitsigns inline diff colors
      hl.GitSignsChangeInLine = { fg = c.git.change, reverse = true }
      hl.GitSignsAddInLine = { fg = c.git.add, reverse = true }
      hl.GitSignsDeleteInLine = { fg = c.git.delete, reverse = true }

      -- Make folds less prominent (especially important for DiffView)
      hl.Folded = { fg = c.blue0, italic = true }

      -- Make diff* transparent for DiffView file panel
      hl.diffAdded = { fg = c.git.add }
      hl.diffRemoved = { fg = c.git.delete }
      hl.diffChanged = { fg = c.git.change }

      -- Make diffview deleted areas dimmer
      hl.DiffviewDiffDeleteDim = { fg = c.fg_gutter }

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

      -- Highlight undo/redo in green
      hl.HighlightUndo = { fg = c.bg, bg = c.green }

      -- hl.Marks = hl.DiagnosticInfo
      hl.MarkSignHL = hl.DiagnosticInfo

      -- Less bright trailing space indicator
      hl.MiniTrailspace = { fg = c.red }

      -- Make win separator more prominent
      hl.WinSeparator = { fg = c.terminal_black }
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
