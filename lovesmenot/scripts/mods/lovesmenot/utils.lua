local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

local utils = {}

function utils.direct_notification(message)
    if Managers.event then
        Managers.event:trigger(
            "event_add_notification_message",
            "alert",
            { text = message } or "",
            nil,
            UISoundEvents.default_click
        )
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
            print(string.format("[%s]:%d",
                info.short_src, info.currentline))
        end
        level = level + 1
    end
end

return utils
