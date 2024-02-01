-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.font_size = 22.0
config.font = wezterm.font("Monaspace Xenon Var")
config.window_background_opacity = 0.8
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.window_padding = {
	left = "1cell",
	right = "1cell",
	top = "1cell",
	bottom = "1cell",
}
config.term = "wezterm"
-- and finally, return the configuration to wezterm
return config
