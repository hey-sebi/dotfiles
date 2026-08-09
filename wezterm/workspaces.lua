---@class WorkspacesModule
local M = {}

local wezterm = require("wezterm")
local mux = wezterm.mux

---@class WorkspaceLayoutConfig
---@field cwd string The root path for the workspace
---@field workspace string The target workspace identifier

---Extracts the terminal directory component to use as a clean workspace title.
---@param path string
---@return string
function M.get_workspace_name(path)
	return path:match("([^/\\]+)[/\\]*$") or path or "default"
end

M._choices_cache = nil
M._cache_time = 0

---Queries zoxide database for recent paths to build selector choices (cached & filtered).
---@return table<{label: string, id: string}>
function M.get_zoxide_choices()
	local now = os.time()
	if M._choices_cache and (now - M._cache_time) < 60 then
		return M._choices_cache
	end

	local success, stdout, _ = wezterm.run_child_process({ "zoxide", "query", "-l" })
	if not success or not stdout then
		return M._choices_cache or {}
	end

	local choices = {}
	-- Ignore noisy non-project directories (builds, dependencies, system data)
	local ignore_pattern =
		"[/\\](node_modules|site%-packages|%.venv|venv|build|target|bin|obj|%.git|%.vscode|%.idea|AppData|%.cache|%.local)"

	for line in stdout:gmatch("[^\r\n]+") do
		line = line:gsub("%s+$", "")
		if line ~= "" and not line:match(ignore_pattern) then
			table.insert(choices, { label = line, id = line })
		end
	end

	M._choices_cache = choices
	M._cache_time = now
	return choices
end

---Verifies whether a given workspace is currently active in the multiplexer.
---@param workspace_name string
---@return boolean
function M.workspace_exists(workspace_name)
	for _, name in ipairs(mux.get_workspace_names()) do
		if name == workspace_name then
			return true
		end
	end
	return false
end

---Spawns the standard 3-tab layout topology into a new workspace.
---@param opts WorkspaceLayoutConfig
function M.populate_dev_layout(opts)
	-- Tab 1: Editor
	local tab1, _, window = mux.spawn_window({
		workspace = opts.workspace,
		cwd = opts.cwd,
		args = { "nvim" },
	})
	tab1:set_title("Editor")

	-- Tab 2: Runner
	local tab2, pane2, _ = window:spawn_tab({ cwd = opts.cwd })
	tab2:set_title("Runner")
	pane2:send_text("sps\n")

	-- Tab 3: AI Agent
	local tab3, _, _ = window:spawn_tab({
		cwd = opts.cwd,
		-- args = { "agy -c" },
	})
	tab3:set_title("Agent")

	tab1:activate()
end

---Switches to an existing workspace or instantiates a fresh layout if missing.
---@param target_dir string
function M.switch_or_create(target_dir)
	local name = M.get_workspace_name(target_dir)

	if not M.workspace_exists(name) then
		wezterm.log_info("Creating new workspace: " .. name .. " at " .. target_dir)
		M.populate_dev_layout({ cwd = target_dir, workspace = name })
	else
		wezterm.log_info("Switching to existing workspace: " .. name)
	end

	mux.set_active_workspace(name)
end

---Appends workspace-related keybindings to the provided WezTerm configuration table.
---@param config table WezTerm config object
function M.apply_to_config(config)
	config.keys = config.keys or {}

	local bindings = {
		-- Zoxide Workspace Picker (Leader + s OR Leader + Shift + W)
		{
			key = "s",
			mods = "LEADER",
			action = wezterm.action_callback(function(window, pane)
				window:perform_action(
					wezterm.action.InputSelector({
						title = "Open Workspace (zoxide)",
						fuzzy = true,
						fuzzy_description = "Search zoxide workspace: ",
						choices = M.get_zoxide_choices(),
						action = wezterm.action_callback(function(_, _, id, _)
							if id then
								M.switch_or_create(id)
							end
						end),
					}),
					pane
				)
			end),
		},

		-- Show Active Workspaces Switcher (Leader + w)
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }),
		},

		-- Switch to previous / next active workspace (Leader + [ / ])
		{
			key = "[",
			mods = "LEADER",
			action = wezterm.action.SwitchWorkspaceRelative(-1),
		},
		{
			key = "]",
			mods = "LEADER",
			action = wezterm.action.SwitchWorkspaceRelative(1),
		},
	}

	for _, b in ipairs(bindings) do
		table.insert(config.keys, b)
	end
end
return M
