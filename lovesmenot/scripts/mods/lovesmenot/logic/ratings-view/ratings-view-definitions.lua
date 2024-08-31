local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local scenegraphDefinition = {
	screen = UIWorkspaceSettings.screen,
}
local widgetDefinitions = {
	background = UIWidget.create_definition({
		{
			pass_type = "rect",
			value = "content/ui/materials/backgrounds/default_square",
			style = {
				color = {
					255,
					0,
					0,
					0,
				},
			},
		},
	}, "screen", nil, nil),
}

local legend_inputs = {
	{
		input_action = "back",
		on_pressed_callback = "cb_on_back_pressed",
		display_name = "loc_settings_menu_close_menu",
		alignment = "left_alignment"
	}
}

return {
	legend_inputs = legend_inputs,
	widget_definitions = widgetDefinitions,
	scenegraph_definition = scenegraphDefinition,
}
