local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- autoreload upon saving this file
config.automatically_reload_config = true

-- looks
config.color_scheme = "catppuccin-macchiato"
config.font = wezterm.font("JetBrains Mono")
config.visual_bell = {}

-- sounds
config.audible_bell = "Disabled"

-- tabs / window decorations / scrolling
config.scrollback_lines = 10000
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.enable_tab_bar = true

-- Customizing the tab bar appearance
local active_tab_bg_color = "#c6a0f6"
config.colors = {
	tab_bar = {
		background = "#1e2030", -- Overall background of the tab bar

		-- Active tab (the one you're viewing)
		active_tab = {
			bg_color = "#c6a0f6", -- Background color of the active tab
			fg_color = "#1e2030", -- Text color of the active tab
		},

		-- Inactive tabs (the ones not currently selected)
		inactive_tab = {
			bg_color = "#333333", -- Background color of inactive tabs
			fg_color = "#808080", -- Text color of inactive tabs
		},

		-- Hovered tab (when the mouse is over a tab)
		inactive_tab_hover = {
			bg_color = "#444444", -- Background color when hovering over inactive tabs
			fg_color = "#c6a0f6", -- Text color when hovering over inactive tabs
		},

		-- New tab button (the '+' button)
		new_tab = {
			bg_color = "#444444", -- Background of the new tab button
			fg_color = "#c6a0f6", -- Text color of the new tab button
		},

		-- Hovered new tab button
		new_tab_hover = {
			bg_color = "#555555", -- Background when hovering over the new tab button
			fg_color = "#c6a0f6", -- Text color when hovering over the new tab button
		},
	},
}

-- Customize the window frame (optional, for titlebar matching)
config.window_frame = {
	font = wezterm.font({ family = "Roboto", weight = "Bold" }),
	active_titlebar_bg = "#1e2030", -- Match title bar color with the terminal background
	inactive_titlebar_bg = "#333333",
}

-- Tabs at the bottom and other tab options
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = false

-- Default shell
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "pwsh" }
else
	config.default_prog = { "zsh" }
end

-- TMUX-like tab/status bar
wezterm.on("update-right-status", function(window, _)
	local SOLID_LEFT_ARROW = ""
	local ARROW_FOREGROUND = { Foreground = { Color = "#c6a0f6" } }
	local prefix = ""

	if window:leader_is_active() then
		-- whitespace + icon
		-- hex keys for some icons:
		--  nerd face (0x1f916)
		--  robot (0x1f30a)
		prefix = " " .. utf8.char(0x1f913)
		-- arrow in color of the tab
		SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	end

	if window:active_tab():tab_id() ~= 1 then
		ARROW_FOREGROUND = { Foreground = { Color = active_tab_bg_color } }
	end -- arrow color based on if tab is first pane

	window:set_left_status(wezterm.format({
		{ Background = { Color = "#b7bdf8" } },
		{ Text = prefix },
		ARROW_FOREGROUND,
		{ Text = SOLID_LEFT_ARROW },
	}))
end)

-- TMUX-like key bindings
config.leader = {
	key = "#",
	mods = "CTRL",
	timeout_milliseconds = 2000,
}
config.keys = {
	{
		mods = "LEADER",
		key = "c",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "LEADER",
		key = "x",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		mods = "LEADER",
		key = "b",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "LEADER",
		key = "n",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		mods = "LEADER|SHIFT",
		key = "%",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER|SHIFT",
		key = '"',
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "LEADER",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "LEADER",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "LEADER",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		mods = "LEADER",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "LEADER",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "LEADER",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "LEADER",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
}

for i = 1, 9 do
	-- leader + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
