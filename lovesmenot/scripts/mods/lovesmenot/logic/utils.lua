local DMF = get_mod("DMF")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")
local utils = {}

function utils.direct_notification(message, isError)
    if Managers.event then
        if not isError then
            Managers.event:trigger(
                "event_add_notification_message",
                "default",
                message,
                nil,
                UISoundEvents.default_click)
        else
            Managers.event:trigger(
                "event_add_notification_message",
                "alert",
                { text = message } or "",
                nil,
                UISoundEvents.default_click
            )
        end
    end
end

function utils.traceback()
    local level = 1
    while true do
        local info = debug.getinfo(level, "Sl")
        if not info then break end
        if info.what == "C" then
            print(level, "C function")
        else
            print(("[%s]:%d"):format(info.short_src, info.currentline))
        end
        level = level + 1
    end
end

local function load_lua_lib(libName)
    utils[libName] = DMF:persistent_table("_" .. libName)
    utils[libName].initialized = utils[libName].initialized or false
    if not utils[libName].initialized then
        utils[libName] = DMF.deepcopy(Mods.lua[libName])
    end
end

load_lua_lib('io')
load_lua_lib('os')

return utils
