-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config = {

	font = wezterm.font("MesloLGS Nerd Font"),
	font_size = 15,

	-- For example, changing the color scheme:
	color_scheme = "tokyonight_night",

	window_decorations = "RESIZE",
	-- window_background_opacity = 1,
	-- macos_window_background_blur = 8,

	-- use_fancy_tab_bar = false,
	tab_max_width = 50,
	hide_tab_bar_if_only_one_tab = true,

	window_frame = {
		-- font = wezterm.font({ family = "MesloLGS Nerd Font", weight = "Bold" }),
		font_size = 14.0,
		active_titlebar_bg = "#1a1b26",
		inactive_titlebar_bg = "#1a1b26",
	},
	colors = {
		tab_bar = {
			-- The color of the inactive tab bar edge/divider
			inactive_tab_edge = "#1a1b26",
			active_tab = {
				-- The color of the background area for the tab
				bg_color = "#2b2042",
				-- The color of the text for the tab
				fg_color = "#f0f0f0",

				-- Specify whether you want "Half", "Normal" or "Bold" intensity for the
				-- label shown for this tab.
				-- The default is "Normal"
				intensity = "Bold",

				-- Specify whether you want "None", "Single" or "Double" underline for
				-- label shown for this tab.
				-- The default is "None"
				underline = "None",

				-- Specify whether you want the text to be italic (true) or not (false)
				-- for this tab.  The default is false.
				italic = true,

				-- Specify whether you want the text to be rendered with strikethrough (true)
				-- or not for this tab.  The default is false.
				strikethrough = false,
			},
			inactive_tab = {
				bg_color = "#1a1b26",
				fg_color = "#808080",

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `inactive_tab`.
			},
		},
	},
}
-- and finally, return the configuration to wezterm
return config

-- vim: ts=2 sts=2 sw=2 et
