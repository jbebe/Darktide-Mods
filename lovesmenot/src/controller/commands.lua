local json = modRequire 'lovesmenot/nurgle_modules/json'
local langUtils = modRequire 'lovesmenot/src/utils/language'

---@param controller LovesMeNot
local function init(controller)
    -- run lua commands in the chat
    controller.dmf:command('lmn_cli', '', function(...)
        -- concat inputs
        local args = { ... }
        local argsString = table.concat(args, ' ')

        -- create global context with 'self' as LovesMeNot
        local globalObj = table.shallow_copy(_G)
        globalObj.self = controller

        -- evaluate string as lua script
        local evalFn = langUtils.loadstring(argsString)
        setfenv(evalFn, globalObj)
        local evalResult = evalFn()

        if type(evalResult) == 'table' then
            evalResult = json.encode(evalResult)
        end
        print(evalResult)
    end)
end

return init
