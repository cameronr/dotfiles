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
    on_colors = function(c)
      c.border_highlight = c.blue

      -- brighten up the git colors, used for gitsigns (column and lualine)
      c.git.add = c.teal
      c.git.change = c.blue
      c.git.delete = c.red1
    end,
    on_highlights = function(hl, c)
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
      else
        -- Diff colors
        -- Brighten changes within a line
        hl.DiffText = { bg = '#a3dca9' }
        -- Make changed lines more green instead of blue
        hl.DiffAdd = { bg = '#cce5cf' }

        -- clean up Neogit diff colors (when committing)
        hl.NeogitDiffAddHighlight = { fg = '#4d6534', bg = hl.DiffAdd.bg }
      end

      hl.TelescopeMatching = { fg = hl.IncSearch.bg }
      hl.CmpItemAbbrMatchFuzzy = { fg = hl.IncSearch.bg }
      hl.CmpItemAbbrMatch = { fg = hl.IncSearch.bg }

      -- clean up Neogit diff colors (when committing)
      hl.NeogitDiffContextHighlight = { bg = hl.Normal.bg }
      hl.NeogitDiffContext = { bg = hl.Normal.bg }

      -- Darken cmp menu (src for the completion)
      hl.CmpItemMenu = hl.CmpGhostText

      -- More subtle
      hl.IblScope = { fg = '#43709B' }

      -- Make folds less prominent (especially important for DiffView)
      hl.Folded = { fg = c.blue0 }

      -- Make the colors in the Lualine x section dimmer
      local lualine = require('lualine.themes.tokyonight-night')
      lualine.normal.x = { fg = hl.Comment.fg, bg = lualine.normal.c.bg }

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
