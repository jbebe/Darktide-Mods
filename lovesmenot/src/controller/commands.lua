local UIRenderer = require 'scripts/managers/ui/ui_renderer'

local json = modRequire 'lovesmenot/nurgle_modules/json'
local langUtils = modRequire 'lovesmenot/src/utils/language'

---@param controller LovesMeNot
local function init(controller)
    controller.dmf:command('lmn_cli', '', function(...)
        local args = { ... }
        local argsString = table.concat(args, ' ')
        local evalFn = langUtils.loadstring(argsString)
        setfenv(evalFn, { self = controller })
        local evalResult = evalFn()
        if type(evalResult) == 'table' then
            evalResult = json.encode(evalResult)
        end
        print(evalResult)
    end)

    controller.dmf:command('lmn_debug', '', function()
        controller.debugging = not controller.debugging
    end)

    controller.dmf:hook_safe(UIRenderer, 'begin_pass', function(self, ui_scenegraph, input_service, dt, render_settings)
        if controller.debugging then
            UIRenderer.debug_render_scenegraph(self, ui_scenegraph)
        end
    end)
end

return init
