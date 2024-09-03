local mod = get_mod("lovesmenot")
local DMF = get_mod("DMF")
local ViewElementInputLegend = mod:original_require(
    "scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ScriptWorld = mod:original_require("scripts/foundation/utilities/script_world")
local UIWidget = mod:original_require("scripts/managers/ui/ui_widget")
local UIWidgetGrid = mod:original_require("scripts/ui/widget_logic/ui_widget_grid")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")
local UIFonts = mod:original_require("scripts/managers/ui/ui_fonts")

local RatingsView = class("RatingsView", "BaseView")

--
-- Init
--

RatingsView.init = function(self, settings, context)
    self._definitions = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view_definitions")
    self._blueprints = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view_blueprints")
    self._settings = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view_settings")
    RatingsView.super.init(self, self._definitions, settings or self._settings, context)
    self._allow_close_hotkey = true
    self._pass_draw = false
    self.ui_manager = Managers.ui
    self:_setup_offscreen_gui()
end

RatingsView._setup_offscreen_gui = function(self)
    local ui_manager = Managers.ui
    local class_name = self.__class_name
    local timer_name = "ui"
    local world_layer = 10
    local world_name = class_name .. "_ui_offscreen_world"
    local view_name = self.view_name
    self._offscreen_world = ui_manager:create_world(world_name, world_layer, timer_name, view_name)
    local shading_environment = self._settings.shading_environment
    local viewport_name = class_name .. "_ui_offscreen_world_viewport"
    local viewport_type = "overlay_offscreen"
    local viewport_layer = 1
    self._offscreen_viewport = ui_manager:create_viewport(self._offscreen_world, viewport_name, viewport_type,
        viewport_layer, shading_environment)
    self._offscreen_viewport_name = viewport_name
    self._ui_offscreen_renderer = ui_manager:create_renderer(class_name .. "_ui_offscreen_renderer",
        self._offscreen_world)
end

RatingsView.on_enter = function(self)
    RatingsView.super.on_enter(self)

    self._using_cursor_navigation = Managers.ui:using_cursor_navigation()
    self:_setup_category_config()
    self:_setup_input_legend()
end

RatingsView._setup_category_config = function(self)
    local entries = {}
    local ratings = mod.rating.accounts
    local i = 1
    mod:add_global_localize_strings({
        loc_lovesmenot_ratings_entry_delete_title = {
            en = "Rehabilitate Account",
        },
        loc_lovesmenot_ratings_entry_delete_description = {
            en = "Do you want to remove the account from this list?",
        },
        loc_lovesmenot_ratings_entry_delete_yes = {
            en = "Yes",
        },
        loc_lovesmenot_ratings_entry_delete_cancel = {
            en = "Cancel",
        },
    })
    for accountId, info in pairs(ratings) do
        local title = ("loc_lovesmenot_ratings_entry_title_%d"):format(i)
        local subtitle = ("loc_lovesmenot_ratings_entry_subtitle_%d"):format(i)
        mod:add_global_localize_strings({
            [title] = {
                en = accountId:sub(1, 40),
            },
            [subtitle] = {
                en = ("Status: %s"):format(info.rating),
            }
        })
        i = i + 1
        local entry = {
            widget_type = "settings_button",
            display_name = title,
            display_name2 = subtitle,
            pressed_function = function(parent, widget, entry)
                local context = {
                    title_text = "loc_lovesmenot_ratings_entry_delete_title",
                    description_text = "loc_lovesmenot_ratings_entry_delete_description",
                    options = {
                        {
                            close_on_pressed = true,
                            text = "loc_lovesmenot_ratings_entry_delete_yes",
                            callback = callback(function()
                                mod.rating.accounts[accountId] = nil
                                mod:persistRating()
                                self:_reload()
                            end),
                        },
                        {
                            close_on_pressed = true,
                            hotkey = "back",
                            template_type = "terminal_button_small",
                            text = "loc_lovesmenot_ratings_entry_delete_cancel",
                        },
                    },
                }
                Managers.event:trigger("event_show_ui_popup", context)
            end
        }
        entries[#entries + 1] = entry
    end

    local scenegraph_id = "grid_content_pivot"
    local callback_name = "cb_on_category_pressed"
    self._category_content_widgets, self._category_alignment_list = self:_setup_content_widgets(entries, scenegraph_id,
        callback_name)
    local scrollbar_widget_id = "scrollbar"
    local grid_scenegraph_id = "background"
    local grid_pivot_scenegraph_id = "grid_content_pivot"
    local grid_spacing = self._settings.grid_spacing
    self._category_content_grid = self:_setup_grid(self._category_content_widgets, self._category_alignment_list,
        grid_scenegraph_id, grid_spacing, true)
    self:_setup_content_grid_scrollbar(self._category_content_grid, scrollbar_widget_id, grid_scenegraph_id,
        grid_pivot_scenegraph_id)
end

RatingsView._setup_content_grid_scrollbar = function(self, grid, widget_id, grid_scenegraph_id, grid_pivot_scenegraph_id)
    local widgets_by_name = self._widgets_by_name
    local scrollbar_widget = widgets_by_name[widget_id]

    if DMF:get("dmf_options_scrolling_speed") and widgets_by_name and widgets_by_name["scrollbar"] then
        widgets_by_name["scrollbar"].content.scroll_speed = DMF:get("dmf_options_scrolling_speed")
    end

    grid:assign_scrollbar(scrollbar_widget, grid_pivot_scenegraph_id, grid_scenegraph_id)
    grid:set_scrollbar_progress(0)
end

RatingsView._setup_grid = function(self, widgets, alignment_list, grid_scenegraph_id, spacing, use_is_focused)
    local ui_scenegraph = self._ui_scenegraph
    local direction = "down"
    local grid = UIWidgetGrid:new(widgets, alignment_list, ui_scenegraph, grid_scenegraph_id, direction, spacing, nil,
        use_is_focused)
    local render_scale = self._render_scale

    grid:set_render_scale(render_scale)

    return grid
end

RatingsView._setup_content_widgets = function(self, content, scenegraph_id, callback_name)
    local widget_definitions = {}
    local widgets = {}
    local alignment_list = {}
    local amount = #content

    for i = amount, 1, -1 do
        local entry = content[i]
        local widget_type = entry.widget_type
        local widget = nil
        local template = self._blueprints[widget_type]
        local size = template.size
        local pass_template = template.pass_template

        if pass_template and not widget_definitions[widget_type] then
            widget_definitions[widget_type] = UIWidget.create_definition(pass_template, scenegraph_id, nil, size)
        end

        local widget_definition = widget_definitions[widget_type]

        if widget_definition then
            local name = scenegraph_id .. "_widget_" .. i
            widget = self:_create_widget(name, widget_definition)

            if template.init then
                template.init(self, widget, entry, callback_name)
            end

            local focus_group = entry.focus_group

            if focus_group then
                widget.content.focus_group = focus_group
            end

            widgets[#widgets + 1] = widget
        end

        alignment_list[#alignment_list + 1] = widget or {
            size = size
        }
    end

    return widgets, alignment_list
end

RatingsView._setup_input_legend = function(self)
    self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)
    local legend_inputs = self._definitions.legend_inputs
    for i = 1, #legend_inputs do
        local legend_input = legend_inputs[i]
        local on_pressed_callback = legend_input.on_pressed_callback and callback(self, legend_input.on_pressed_callback)
        local visibility_function = legend_input.visibility_function
        if legend_input.display_name == "loc_scoreboard_delete" then
            visibility_function = function()
                return self.entry
            end
        end
        self._input_legend_element:add_entry(legend_input.display_name, legend_input.input_action, visibility_function,
            on_pressed_callback, legend_input.alignment)
    end
end

--
-- Present
--

RatingsView.draw = function(self, dt, t, input_service, layer)
    self:_draw_elements(dt, t, self._ui_renderer, self._render_settings, input_service)

    self._category_content_grid:update(dt, t, input_service)

    local widgets_by_name = self._widgets_by_name
    local grid_interaction_widget = widgets_by_name.grid_interaction
    self:_draw_grid(self._category_content_grid, self._category_content_widgets, grid_interaction_widget, dt, t,
        input_service)
    RatingsView.super.draw(self, dt, t, input_service, layer)
end

RatingsView._draw_elements = function(self, dt, t, ui_renderer, render_settings, input_service)
    RatingsView.super._draw_elements(self, dt, t, ui_renderer, render_settings, input_service)
end

RatingsView._draw_grid = function(self, grid, widgets, interaction_widget, dt, t, input_service)
    local is_grid_hovered = not self._using_cursor_navigation or interaction_widget.content.hotspot.is_hover or false
    local null_input_service = input_service:null_service()
    local render_settings = self._render_settings
    local ui_renderer = self._ui_offscreen_renderer
    local ui_scenegraph = self._ui_scenegraph

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, render_settings)

    for j = 1, #widgets do
        local widget = widgets[j]
        local draw = widget ~= self._selected_settings_widget

        if draw then
            if self._selected_settings_widget then
                ui_renderer.input_service = null_input_service
            end

            if grid:is_widget_visible(widget) then
                local hotspot = widget.content.hotspot

                if hotspot then
                    hotspot.force_disabled = not is_grid_hovered
                    local is_active = hotspot.is_focused or hotspot.is_hover

                    if is_active and widget.content.entry and (widget.content.entry.tooltip_text or widget.content.entry.disabled_by and not table.is_empty(widget.content.entry.disabled_by)) then
                        self:_set_tooltip_data(widget)
                    end
                end

                UIWidget.draw(widget, ui_renderer)
            end
        end
    end

    UIRenderer.end_pass(ui_renderer)
end

--
-- Callbacks
--

RatingsView.cb_on_category_pressed = function(self, widget, entry)
    local pressed_function = entry.pressed_function

    if pressed_function then
        pressed_function(self, widget, entry)
    end
end

RatingsView.cb_on_back_pressed = function(self)
    self.ui_manager:close_view("ratings_view")
end

--
-- Close
--

RatingsView.on_exit = function(self)
    if self._input_legend_element then
        self._input_legend_element = nil
        self:_remove_element("input_legend")
    end

    if self._ui_offscreen_renderer then
        self._ui_offscreen_renderer = nil

        Managers.ui:destroy_renderer(self.__class_name .. "_ui_offscreen_renderer")

        local offscreen_world = self._offscreen_world
        local offscreen_viewport_name = self._offscreen_viewport_name

        ScriptWorld.destroy_viewport(offscreen_world, offscreen_viewport_name)
        Managers.ui:destroy_world(offscreen_world)

        self._offscreen_viewport = nil
        self._offscreen_viewport_name = nil
        self._offscreen_world = nil
    end

    if self.ui_manager:view_active("ratings_view") and not self.ui_manager:is_view_closing("ratings_view") then
        self.ui_manager:close_view("ratings_view", true)
    end

    RatingsView.super.on_exit(self)
end

RatingsView._reload = function(self)
    if self.ui_manager:view_active("ratings_view") and not self.ui_manager:is_view_closing("ratings_view") then
        self.ui_manager:close_view("ratings_view", true)
    end
    self:_setup_category_config()
end

--
-- Misc
--

mod.shrink_text = function(self, text, style, max_width, ui_renderer)
    if ui_renderer then
        local width = max_width + 10
        local fsize = (style.font_size or 20) + 1
        while width > max_width - 20 do
            fsize = fsize - 1
            style.font_size = fsize
            local font_type = style.font_type
            local scale = ui_renderer.scale or 1
            local scaled_font_size = UIFonts.scaled_size(fsize, scale)
            width = UIRenderer.text_size(ui_renderer, text, font_type, scaled_font_size)
        end
    end
end

return RatingsView
