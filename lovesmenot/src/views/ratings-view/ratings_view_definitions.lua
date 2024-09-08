---@module 'lovesmenot/src/types/darktide-types'

local UIWorkspaceSettings = require "scripts/settings/ui/ui_workspace_settings"
local UIWidget = require "scripts/managers/ui/ui_widget"
local UIFontSettings = require "scripts/managers/ui/ui_font_settings"
local ScrollbarPassTemplates = require "scripts/ui/pass_templates/scrollbar_pass_templates"
local _view_settings = require "lovesmenot/src/views/ratings-view/ratings_view_settings"

---@param controller LovesMeNot
local function init(controller)
	local grid_size = _view_settings.grid_size
	local grid_width = grid_size[1]
	local grid_height = grid_size[2]
	local scrollbar_width = _view_settings.scrollbar_width
	local grid_blur_edge_size = _view_settings.grid_blur_edge_size
	local mask_size = {
		grid_width + grid_blur_edge_size[1] * 2,
		grid_height + grid_blur_edge_size[2] * 2
	}

	local scenegraphDefinition = {
		screen = UIWorkspaceSettings.screen,
		background = {
			vertical_alignment = "top",
			parent = "screen",
			horizontal_alignment = "left",
			size = { grid_width, grid_height },
			position = { 180, 240, 1 }
		},
		background_icon = {
			horizontal_alignment = "center",
			parent = "screen",
			vertical_alignment = "center",
			size = { 1250, 1250 },
			position = { 0, 0, 0 },
		},
		title_divider = {
			vertical_alignment = "top",
			parent = "screen",
			horizontal_alignment = "left",
			size = { 335, 18 },
			position = { 180, 145, 1 }
		},
		title_text = {
			vertical_alignment = "bottom",
			parent = "title_divider",
			horizontal_alignment = "left",
			size = { 500, 50 },
			position = { 0, -35, 1 }
		},
		description_text = {
			vertical_alignment = "top",
			parent = "title_divider",
			horizontal_alignment = "left",
			size = { 1000, 50 },
			position = { 0, 35, 0 }
		},
		scrollbar = {
			vertical_alignment = "center",
			parent = "background",
			horizontal_alignment = "right",
			size = { scrollbar_width, grid_height },
			position = { 50, 0, 1 }
		},
		grid_mask = {
			vertical_alignment = "center",
			parent = "background",
			horizontal_alignment = "center",
			size = mask_size,
			position = { 0, 0, 0 }
		},
		grid_interaction = {
			vertical_alignment = "top",
			parent = "background",
			horizontal_alignment = "left",
			size = { grid_width + scrollbar_width * 2, mask_size[2] },
			position = { 0, 0, 0 }
		},
		grid_start = {
			vertical_alignment = "top",
			parent = "background",
			horizontal_alignment = "left",
			size = { 0, 0 },
			position = { 0, 0, 0 }
		},
		grid_content_pivot = {
			vertical_alignment = "top",
			parent = "grid_start",
			horizontal_alignment = "left",
			size = { 0, 0 },
			position = { 0, 0, 1 }
		},
		button = {
			vertical_alignment = "left",
			parent = "grid_content_pivot",
			horizontal_alignment = "top",
			size = { 500, 64 },
			position = { 0, 0, 0 }
		},
	}

	local widgetDefinitions = {
		background = UIWidget.create_definition({
			{
				pass_type = "rect",
				style = {
					color = Color.black(100, true),
				},
			},
			{
				pass_type = "texture",
				value = "content/ui/materials/backgrounds/terminal_basic",
				style = {
					horizontal_alignemt = "center",
					scale_to_material = true,
					vertical_alignemnt = "center",
					size_addition = {
						40,
						40,
					},
					offset = {
						-20,
						-20,
						0,
					},
					color = Color.terminal_grid_background_gradient(100, true),
				},
			},
		}, "screen"),
		background_icon = UIWidget.create_definition({
			{
				pass_type = "slug_icon",
				value = "content/ui/vector_textures/symbols/cog_skull_01",
				style = {
					offset = { 0, 0, 0 },
					color = { 60, 0, 0, 0 },
				},
			},
		}, "background_icon"),
		title_divider = UIWidget.create_definition({
			{
				pass_type = "texture",
				value = "content/ui/materials/dividers/skull_rendered_left_01"
			}
		}, "title_divider"),
		title_text = UIWidget.create_definition({
			{
				value_id = "text",
				style_id = "text",
				pass_type = "text",
				value = controller.dmf:localize("lovesmenot_ratingsview_title"),
				style = table.clone(UIFontSettings.header_1)
			}
		}, "title_text"),
		description_text = UIWidget.create_definition({
			{
				pass_type = "text",
				value_id = "text_2",
				style_id = "text_2",
				value = controller.dmf:localize("lovesmenot_ratingsview_description"),
				style = table.clone(UIFontSettings.body_small)
			}
		}, "description_text"),
		scrollbar = UIWidget.create_definition(ScrollbarPassTemplates.default_scrollbar, "scrollbar"),
		grid_mask = UIWidget.create_definition({
			{
				value = "content/ui/materials/offscreen_masks/ui_overlay_offscreen_vertical_blur",
				pass_type = "texture",
				style = {
					color = { 255, 255, 255, 255 }
				}
			}
		}, "grid_mask"),
		grid_interaction = UIWidget.create_definition({
			{
				pass_type = "hotspot",
				content_id = "hotspot"
			}
		}, "grid_interaction"),
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
end

return init
