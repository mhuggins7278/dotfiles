-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

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
		return "catppuccin-mocha"
	else
		return "catppuccin-latte"
	end
end

config.font_size = 14.0
config.font = wezterm.font("Monaspace Radon Var")
config.window_background_opacity = 1
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.macos_window_background_blur = 0
config.term = "wezterm"
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.send_composed_key_when_right_alt_is_pressed = false

-- and finally, return the configuration to wezterm
return config
