local mod = get_mod("lovesmenot")
local json = mod:io_dofile("lovesmenot/scripts/mods/lovesmenot/thirdparty/json")
local UIRenderer = mod:original_require("scripts/managers/ui/ui_renderer")

mod:command("lmn_cmd", "Run simple functions (reset)", function(functionName)
    if functionName == "reset" then
        mod.initialized = true
        mod.localPlayer = Managers.player:local_player_safe(1)
        mod:loadRating()
        mod.isInMission = mod:_isInMission()
    end
end)

mod:command("lmn_get", "Get property on local player object", function(modProperty, subProperty)
    local value = mod[modProperty]
    if subProperty then
        value = value[subProperty]
    end

    mod:echo(json.encode(value))
end)

mod:command("lmn_save", "Save state to file", function()
    mod:persistRating()
end)

mod:command("lmn_debug", "", function()
    mod.debugging = not mod.debugging
end)

mod:hook_safe(UIRenderer, "begin_pass", function(self, ui_scenegraph, input_service, dt, render_settings)
    if mod.debugging then
        UIRenderer.debug_render_scenegraph(self, ui_scenegraph)
    end
end)
