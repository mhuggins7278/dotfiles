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

--a For example, changing the color scheme:

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

config.font_size = 14.0
-- config.max_fps = 120
config.font = wezterm.font_with_fallback({
	{
		family = "Monaspace Radon Var",
		weight = "Bold",
		harfbuzz_features = {
			"calt=1",
			"liga=1",
			"dlig=1",
			"ss01=1",
			"ss02=1",
			"ss03=1",
			"ss04=1",
			"ss05=1",
			"ss06=1",
			"ss07=1",
			"ss08=1",
		},
	},
})
config.window_background_opacity = 0.6
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.macos_window_background_blur = 15
config.front_end = "WebGpu"
config.max_fps = 120
config.webgpu_power_preference = "HighPerformance"
config.term = "wezterm"
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.send_composed_key_when_right_alt_is_pressed = false

-- and finally, return the configuration to wezterm
return config
