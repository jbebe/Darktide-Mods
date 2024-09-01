local mod = get_mod("lovesmenot")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local _view_settings = mod:io_dofile(
	"lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view_settings")
local grid_size = _view_settings.grid_size
local grid_width = grid_size[1]
local grid_height = grid_size[2]

local scenegraphDefinition = {
	screen = UIWorkspaceSettings.screen,
	background = {
		vertical_alignment = "top",
		parent = "screen",
		horizontal_alignment = "left",
		size = { grid_width, grid_height },
		position = { 180, 240, 1 }
	},
}
local widgetDefinitions = {
	background = UIWidget.create_definition({
		{
			pass_type = "rect",
			style = {
				color = { 160, 0, 0, 0 }
			}
		}
	}, "screen"),
}

local legendInputs = {
	{
		input_action = "back",
		on_pressed_callback = "cb_on_back_pressed",
		display_name = "loc_settings_menu_close_menu",
		alignment = "left_alignment"
	}
}

local ratingsViewDefinitions = {
	legend_inputs = legendInputs,
	widget_definitions = widgetDefinitions,
	scenegraph_definition = scenegraphDefinition
}

return settings("RatingsViewDefinitions", ratingsViewDefinitions)
