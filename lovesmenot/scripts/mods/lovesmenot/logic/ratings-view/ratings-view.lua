local mod = get_mod("lovesmenot")
local definitions = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/logic/ratings-view/ratings-view-definitions")
local BaseView = require("scripts/ui/views/base_view")
local RatingsView = class("RatingsView", "BaseView")

RatingsView.init = function(self, settings, context)
    self._pass_draw = false
    self._ui_manager = Managers.ui
    self._definitions = definitions
    RatingsView.super.init(self, self._definitions, settings)
end

RatingsView.draw = function(self, dt, t, input_service, layer)
    BaseView.draw(self, dt, t, input_service, layer)

    Managers.ui:render_loading_icon()
end

RatingsView.on_exit = function(self)
    if self._ui_manager:view_active("ratings_view") and not self._ui_manager:is_view_closing("ratings_view") then
        self._ui_manager:close_view("ratings_view", true)
    end

    RatingsView.super.on_exit(self)
end

RatingsView.cb_on_back_pressed = function(self)
    self.ui_manager:close_view("ratings_view")
end

return RatingsView
