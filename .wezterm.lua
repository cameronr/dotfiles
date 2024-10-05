-- Pull in the wezterm API
local wezterm = require("wezterm")

-- From:
-- https://wezfurlong.org/wezterm/config/lua/window-events/user-var-changed.html
wezterm.on("user-var-changed", function(window, _, name, value)
  wezterm.log_info("var", name, value)

  if name == "FORCE_DAY_MODE" then
    local overrides = window:get_config_overrides() or {}
    if value == "tokyonight_day" and not overrides.color_scheme then
      overrides.color_scheme = "tokyonight_day"
    else
      overrides.color_scheme = nil
    end
    window:set_config_overrides(overrides)
  end
end)

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
  options = {
    icons_enabled = true,
    theme = "tokyonight_night",
    color_overrides = {},
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    component_separators = {
      left = wezterm.nerdfonts.pl_left_soft_divider,
      right = wezterm.nerdfonts.pl_right_soft_divider,
    },
    tab_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
  },
  sections = {
    tabline_a = { "mode" },
    -- tabline_a = {},
    tabline_b = {},
    -- tabline_c = { " " },
    -- tab_active = {
    --   "index",
    --   { "parent", padding = 0 },
    --   "/",
    --   { "cwd", padding = { left = 0, right = 1 } },
    --   { "zoomed", padding = 0 },
    -- },
    -- tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },

    tab_active = {
      "index",
      { "process", padding = { left = 0, right = 1 } },
      { "zoomed", padding = 0 },
    },
    tab_inactive = {
      "index",
      { "process", padding = { left = 0, right = 1 } },
    },

    -- tabline_x = { 'ram', 'cpu' },
    -- tabline_y = { "datetime", "battery" },
    -- tabline_z = { "hostname" },
    tabline_y = { "battery" },
    tabline_z = { "datetime" },

    tabline_x = {},
  },
  extensions = {},
})

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config = {

  font = wezterm.font("MesloLGS Nerd Font"),
  font_size = 19,

  -- For example, changing the color scheme:
  color_scheme = "tokyonight_night",

  window_decorations = "RESIZE",
  window_background_opacity = 1,
  -- macos_window_background_blur = 8,

  -- use_fancy_tab_bar = false,
  -- tab_max_width = 50,
  hide_tab_bar_if_only_one_tab = true,

  window_frame = {
    font = wezterm.font({ family = "MesloLGS Nerd Font", weight = "Bold" }),
    font_size = 14.0,
    -- active_titlebar_bg = "#1a1b26",
    -- inactive_titlebar_bg = "#1a1b26",
  },
  -- colors = {
  --   tab_bar = {
  --     -- The color of the inactive tab bar edge/divider
  --     inactive_tab_edge = "#1a1b26",
  --     active_tab = {
  --       -- The color of the background area for the tab
  --       bg_color = "#2b2042",
  --       -- The color of the text for the tab
  --       fg_color = "#f0f0f0",
  --
  --       -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
  --       -- label shown for this tab.
  --       -- The default is "Normal"
  --       intensity = "Bold",
  --
  --       -- Specify whether you want "None", "Single" or "Double" underline for
  --       -- label shown for this tab.
  --       -- The default is "None"
  --       underline = "None",
  --
  --       -- Specify whether you want the text to be italic (true) or not (false)
  --       -- for this tab.  The default is false.
  --       italic = true,
  --
  --       -- Specify whether you want the text to be rendered with strikethrough (true)
  --       -- or not for this tab.  The default is false.
  --       strikethrough = false,
  --     },
  --     inactive_tab = {
  --       bg_color = "#1a1b26",
  --       fg_color = "#808080",
  --
  --       -- The same options that were listed under the `active_tab` section above
  --       -- can also be used for `inactive_tab`.
  --     },
  --   },
  -- },
  bypass_mouse_reporting_modifiers = "SHIFT",
}

tabline.apply_to_config(config)

-- and finally, return the configuration to wezterm
return config

-- vim: ts=2 sts=2 sw=2 et
