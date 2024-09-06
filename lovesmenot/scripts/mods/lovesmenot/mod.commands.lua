local mod = get_mod("lovesmenot")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")

mod:command("lmn_debug", "", function()
    mod.debugging = not mod.debugging
end)

mod:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
    if mod.debugging then
        UIRenderer.debug_render_scenegraph(self, ui_scenegraph)
    end
end)
