local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.initial_cols = 120
config.initial_rows = 28

config.font_size = 11
config.color_scheme = "GruvboxDark"
-- config.line_height = 0.99

config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return config
