local mod = get_mod("lovesmenot")
local BaseView = require("scripts/ui/views/base_view")
local RatingsView = class("RatingsView", "BaseView")
local ViewElementInputLegend = mod:original_require(
    "scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local ScriptWorld = mod:original_require("scripts/foundation/utilities/script_world")

--
-- Init
--

RatingsView.init = function(self, settings, context)
    self._definitions = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings_view_definitions")
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
    self:_setup_input_legend()
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
    RatingsView.super.draw(self, dt, t, input_service, layer)
end

RatingsView._draw_elements = function(self, dt, t, ui_renderer, render_settings, input_service)
    RatingsView.super._draw_elements(self, dt, t, ui_renderer, render_settings, input_service)
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

RatingsView.cb_on_back_pressed = function(self)
    self.ui_manager:close_view("ratings_view")
end

return RatingsView
