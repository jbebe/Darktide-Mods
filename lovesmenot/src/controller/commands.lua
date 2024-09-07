local UIRenderer = require "scripts/managers/ui/ui_renderer"

---@param controller LovesMeNot
local function init(controller)
    controller.dmf:command("lmn_debug", "", function()
        controller.debugging = not controller.debugging
    end)

    controller.dmf:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
        if controller.debugging then
            UIRenderer.debug_render_scenegraph(self, ui_scenegraph)
        end
    end)
end

return init
